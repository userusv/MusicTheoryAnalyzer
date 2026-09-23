#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QAudioSink>
#include <QAudioDevice>
#include <QAudioFormat>
#include <QBuffer>
#include <QTimer>
#include <QtMath>
#include <QVector>

#include <fluidsynth.h>
#include <vector>
#include <string>
#include <algorithm>
#include <cmath>
#include <cstring>

#include "MidiFile.h"

struct NoteInterval
{
    double start;
    double end;
    int pitch;
};

class MusicAnalyzer : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString key READ key NOTIFY analysisChanged)
    Q_PROPERTY(double duration READ duration NOTIFY analysisChanged)
    Q_PROPERTY(int trackCount READ trackCount NOTIFY analysisChanged)
    Q_PROPERTY(double tempo READ tempo NOTIFY analysisChanged)
    Q_PROPERTY(int totalNotes READ totalNotes NOTIFY analysisChanged)
    Q_PROPERTY(double averagePitch READ averagePitch NOTIFY analysisChanged)
    Q_PROPERTY(double averageDuration READ averageDuration NOTIFY analysisChanged)
    Q_PROPERTY(int lowestPitch READ lowestPitch NOTIFY analysisChanged)
    Q_PROPERTY(int highestPitch READ highestPitch NOTIFY analysisChanged)
    Q_PROPERTY(QVariantList noteFrequency READ noteFrequency NOTIFY analysisChanged)
    Q_PROPERTY(QVariantList chordProgression READ chordProgression NOTIFY analysisChanged)
    Q_PROPERTY(QVariantList noteTimeline READ noteTimeline NOTIFY analysisChanged)
    Q_PROPERTY(QString status READ status NOTIFY analysisChanged)
    Q_PROPERTY(bool playing READ playing NOTIFY playbackChanged)
    Q_PROPERTY(double playbackPosition READ playbackPosition NOTIFY playbackChanged)

public:
    explicit MusicAnalyzer(QObject *parent = nullptr)
        : QObject(parent)
    {
        connect(&m_playbackTimer, &QTimer::timeout,
                this, &MusicAnalyzer::updatePlaybackPosition);

        m_playbackTimer.setInterval(20);
    }

    ~MusicAnalyzer()
    {
        stopPlayback();
        clearAudio();
    }

    Q_INVOKABLE void analyze(const QString &filePath)
    {
        stopPlayback();
        clearAudio();

        m_key = "Unknown";
        m_duration = 0.0;
        m_trackCount = 0;
        m_tempo = 0.0;
        m_totalNotes = 0;
        m_averagePitch = 0.0;
        m_averageDuration = 0.0;
        m_lowestPitch = 0;
        m_highestPitch = 0;
        m_noteFrequency.clear();
        m_chordProgression.clear();
        m_noteTimeline.clear();
        m_notes.clear();
        m_status = "Loading...";

        emit analysisChanged();

        smf::MidiFile midi;

        if (!midi.read(filePath.toStdString()))
        {
            m_status = "Could not read MIDI file";
            emit analysisChanged();
            return;
        }

        midi.doTimeAnalysis();
        midi.linkNotePairs();

        m_trackCount = midi.getTrackCount();
        m_duration = midi.getFileDurationInSeconds();

        for (int track = 0; track < midi.getTrackCount(); ++track)
        {
            for (int eventIndex = 0; eventIndex < midi[track].size(); ++eventIndex)
            {
                smf::MidiEvent &event = midi[track][eventIndex];

                if (event.isTempo())
                {
                    const double bpm = event.getTempoBPM();
                    if (bpm > 0.0)
                        m_tempo = bpm;
                }

                if (!event.isNoteOn())
                    continue;

                const int pitch = event.getKeyNumber();

                double start = event.seconds;
                double end = start;

                if (event.isLinked())
                {
                    const smf::MidiEvent *off = event.getLinkedEvent();
                    if (off)
                        end = off->seconds;
                }

                if (end <= start)
                    end = start + 0.05;

                NoteInterval note;
                note.start = start;
                note.end = end;
                note.pitch = pitch;

                m_notes.push_back(note);
            }
        }

        std::sort(m_notes.begin(), m_notes.end(),
                  [](const NoteInterval &a, const NoteInterval &b)
                  {
                      if (a.start != b.start)
                          return a.start < b.start;
                      return a.pitch < b.pitch;
                  });

        m_totalNotes = static_cast<int>(m_notes.size());

        QVector<int> frequency(12, 0);
        double pitchSum = 0.0;
        double durationSum = 0.0;

        m_lowestPitch = m_notes.empty() ? 0 : m_notes.front().pitch;
        m_highestPitch = m_notes.empty() ? 0 : m_notes.front().pitch;

        double shortest = m_notes.empty() ? 0.0 : 999999.0;
        double longest = 0.0;

        for (const NoteInterval &note : m_notes)
        {
            const double noteDuration = note.end - note.start;
            const int pc = ((note.pitch % 12) + 12) % 12;

            frequency[pc]++;
            pitchSum += note.pitch;
            durationSum += noteDuration;

            m_lowestPitch = std::min(m_lowestPitch, note.pitch);
            m_highestPitch = std::max(m_highestPitch, note.pitch);

            shortest = std::min(shortest, noteDuration);
            longest = std::max(longest, noteDuration);
        }

        if (!m_notes.empty())
        {
            m_averagePitch = pitchSum / m_notes.size();
            m_averageDuration = durationSum / m_notes.size();
        }

        const char *names[] =
            {
                "C", "C#", "D", "Eb", "E", "F",
                "F#", "G", "Ab", "A", "Bb", "B"
            };

        for (int i = 0; i < 12; ++i)
        {
            QVariantMap item;
            item["note"] = QString::fromLatin1(names[i]);
            item["count"] = frequency[i];
            m_noteFrequency.append(item);
        }

        detectKey(frequency);
        buildChords();
        buildTimeline();

        m_status = "Analysis complete";

        emit analysisChanged();
    }

    Q_INVOKABLE void playPlayback()
    {
        if (m_notes.empty())
            return;

        if (m_audioData.isEmpty())
        {
            if (!buildAudio())
            {
                m_status = "Could not create audio";
                emit analysisChanged();
                return;
            }
        }

        if (m_audioSink)
        {
            m_audioSink->stop();
            delete m_audioSink;
            m_audioSink = nullptr;
        }

        m_audioBuffer.close();
        m_audioBuffer.setData(m_audioData);
        m_audioBuffer.open(QIODevice::ReadOnly);

        // Let Qt select the system default audio output.
        m_audioSink = new QAudioSink(m_audioFormat, this);
        m_audioSink->setBufferSize(65536);


        m_playbackPosition = bytesToSeconds(0);
        m_playbackTimer.start();
        m_audioSink->start(&m_audioBuffer);
        if (m_audioSink->error() != QAudio::NoError)
        {
            m_status = "Audio output error";
            m_audioSink->stop();
            m_playing = false;
            emit analysisChanged();
            emit playbackChanged();
            return;
        }

        m_playing = true;
        emit playbackChanged();


    }

    Q_INVOKABLE void pausePlayback()
    {
        if (!m_audioSink)
            return;

        if (m_playing)
        {
            m_audioSink->suspend();
            m_playing = false;
            m_playbackTimer.stop();
        }
        else
        {
            m_audioSink->resume();
            m_playing = true;
            m_playbackTimer.start();
        }

        emit playbackChanged();
    }

    Q_INVOKABLE void stopPlayback()
    {
        m_playbackTimer.stop();

        if (m_audioSink)
            m_audioSink->stop();

        m_audioBuffer.close();

        m_playing = false;
        m_playbackPosition = 0.0;

        emit playbackChanged();
    }

    Q_INVOKABLE void seekPlayback(double seconds)
    {
        if (m_audioData.isEmpty())
            return;

        seconds = qBound(0.0, seconds, m_duration);

        const qint64 bytePosition = secondsToBytes(seconds);

        const bool wasPlaying = m_playing;

        if (m_audioSink)
            m_audioSink->stop();

        m_audioBuffer.close();
        m_audioBuffer.setData(m_audioData);
        m_audioBuffer.open(QIODevice::ReadOnly);
        m_audioBuffer.seek(bytePosition);

        m_playbackPosition = seconds;

        if (wasPlaying && m_audioSink)
        {
            m_audioSink->start(&m_audioBuffer);
            m_playbackTimer.start();
        }

        emit playbackChanged();
    }

    QString key() const { return m_key; }
    double duration() const { return m_duration; }
    int trackCount() const { return m_trackCount; }
    double tempo() const { return m_tempo; }
    int totalNotes() const { return m_totalNotes; }
    double averagePitch() const { return m_averagePitch; }
    double averageDuration() const { return m_averageDuration; }
    int lowestPitch() const { return m_lowestPitch; }
    int highestPitch() const { return m_highestPitch; }
    QVariantList noteFrequency() const { return m_noteFrequency; }
    QVariantList chordProgression() const { return m_chordProgression; }
    QVariantList noteTimeline() const { return m_noteTimeline; }
    QString status() const { return m_status; }
    bool playing() const { return m_playing; }
    double playbackPosition() const { return m_playbackPosition; }

signals:
    void analysisChanged();
    void playbackChanged();

private:
    void detectKey(const QVector<int> &frequency)
    {
        const int majorScale[] = {0, 2, 4, 5, 7, 9, 11};
        const int minorScale[] = {0, 2, 3, 5, 7, 8, 10};

        int bestScore = -1;
        QString bestKey = "Unknown";

        const char *names[] =
            {
                "C", "C#", "D", "Eb", "E", "F",
                "F#", "G", "Ab", "A", "Bb", "B"
            };

        for (int root = 0; root < 12; ++root)
        {
            int score = 0;

            for (int interval : majorScale)
                score += frequency[(root + interval) % 12];

            if (score > bestScore)
            {
                bestScore = score;
                bestKey = QString::fromLatin1(names[root]) + " Major";
            }
        }

        for (int root = 0; root < 12; ++root)
        {
            int score = 0;

            for (int interval : minorScale)
                score += frequency[(root + interval) % 12];

            if (score > bestScore)
            {
                bestScore = score;
                bestKey = QString::fromLatin1(names[root]) + " Minor";
            }
        }

        m_key = bestKey;
    }

    void buildChords()
    {
        m_chordProgression.clear();

        if (m_duration <= 0.0 || m_notes.empty())
            return;

        const char *names[] =
            {
                "C", "C#", "D", "Eb", "E", "F",
                "F#", "G", "Ab", "A", "Bb", "B"
            };

        const int windowCount = static_cast<int>(qCeil(m_duration));

        for (int w = 0; w < windowCount; ++w)
        {
            const double start = w;
            const double end = std::min(m_duration, w + 1.0);

            double weighted[12] = {};

            for (const NoteInterval &note : m_notes)
            {
                const double overlap =
                    std::max(0.0,
                             std::min(note.end, end) -
                                 std::max(note.start, start));

                if (overlap <= 0.0)
                    continue;

                const int pc = ((note.pitch % 12) + 12) % 12;
                weighted[pc] += overlap;
            }

            double bestScore = 0.0;
            int bestRoot = -1;
            QString bestChord = "Uncertain";

            for (int root = 0; root < 12; ++root)
            {
                const int third = (root + 4) % 12;
                const int fifth = (root + 7) % 12;

                const double chordScore =
                    weighted[root] +
                    weighted[third] +
                    weighted[fifth];

                if (chordScore > bestScore)
                {
                    bestScore = chordScore;
                    bestRoot = root;
                }
            }

            double totalWeight = 0.0;
            for (double value : weighted)
                totalWeight += value;

            if (bestRoot >= 0 && totalWeight > 0.0 &&
                bestScore / totalWeight >= 0.55)
            {
                bestChord =
                    QString::fromLatin1(names[bestRoot]) + " Major";
            }

            QVariantMap chord;
            chord["start"] = start;
            chord["end"] = end;
            chord["chord"] = bestChord;

            m_chordProgression.append(chord);
        }
    }

    void buildTimeline()
    {
        m_noteTimeline.clear();

        const char *names[] =
            {
                "C", "C#", "D", "Eb", "E", "F",
                "F#", "G", "Ab", "A", "Bb", "B"
            };

        for (const NoteInterval &note : m_notes)
        {
            QVariantMap item;
            item["start"] = note.start;
            item["end"] = note.end;
            item["pitch"] = note.pitch;
            item["note"] =
                QString::fromLatin1(names[((note.pitch % 12) + 12) % 12]);

            m_noteTimeline.append(item);
        }
    }

    bool buildAudio()
    {
        clearAudio();

        if (m_notes.empty() || m_duration <= 0.0)
            return false;

        constexpr int sampleRate = 44100;
        constexpr int channels = 2;

        fluid_settings_t *settings = new_fluid_settings();
        if (!settings)
            return false;

        fluid_settings_setnum(settings, "synth.sample-rate", sampleRate);
        fluid_settings_setint(settings, "synth.polyphony", 128);
        fluid_settings_setnum(settings, "synth.gain", 0.65);

        fluid_synth_t *synth = new_fluid_synth(settings);
        if (!synth)
        {
            delete_fluid_settings(settings);
            return false;
        }

        const QString soundFontPath =
            QCoreApplication::applicationDirPath() +
            "/../share/sounds/sf2/FluidR3_GM.sf2";

        const QByteArray soundFontPathBytes =
            soundFontPath.toUtf8();

        const char *soundFont =
            soundFontPathBytes.constData();

        const int soundFontId =
            fluid_synth_sfload(synth, soundFont, 1);

        if (soundFontId < 0)
        {
            delete_fluid_synth(synth);
            delete_fluid_settings(settings);
            return false;
        }

        // General MIDI piano: bank 0, program 0.
        if (fluid_synth_program_select(synth, 0,
                                       soundFontId, 0, 0) != FLUID_OK)
        {
            fluid_synth_sfunload(synth, soundFontId, 0);
            delete_fluid_synth(synth);
            delete_fluid_settings(settings);
            return false;
        }

        const qint64 totalFrames =
            static_cast<qint64>(qCeil(m_duration * sampleRate)) + 1024;

        const qint64 totalSamples = totalFrames * channels;

        m_audioData.resize(totalSamples * static_cast<qint64>(sizeof(qint16)));
        std::fill(m_audioData.begin(), m_audioData.end(), '\0');

        struct MidiEvent
        {
            qint64 frame;
            int type;
            int pitch;
        };

        std::vector<MidiEvent> events;
        events.reserve(m_notes.size() * 2);

        for (const NoteInterval &note : m_notes)
        {
            const qint64 startFrame =
                qBound<qint64>(0,
                               static_cast<qint64>(std::llround(note.start * sampleRate)),
                               totalFrames - 1);

            const qint64 endFrame =
                qBound<qint64>(startFrame + 1,
                               static_cast<qint64>(std::llround(note.end * sampleRate)),
                               totalFrames - 1);

            events.push_back({startFrame, 1, note.pitch});
            events.push_back({endFrame, 0, note.pitch});
        }

        std::sort(events.begin(), events.end(),
                  [](const MidiEvent &a, const MidiEvent &b)
                  {
                      if (a.frame != b.frame)
                          return a.frame < b.frame;

                      return a.type < b.type;
                  });

        qint64 currentFrame = 0;

        for (const MidiEvent &event : events)
        {
            if (event.frame > currentFrame)
            {
                const int frames =
                    static_cast<int>(
                        std::min<qint64>(
                            event.frame - currentFrame,
                            8192));

                qint16 *output =
                    reinterpret_cast<qint16 *>(
                        m_audioData.data() +
                        currentFrame * channels *
                            static_cast<qint64>(sizeof(qint16)));

                qint64 remaining = event.frame - currentFrame;

                while (remaining > 0)
                {
                    const int block =
                        static_cast<int>(
                            std::min<qint64>(remaining, frames));

                    fluid_synth_write_s16(
                        synth,
                        block,
                        output,
                        0,
                        channels,
                        output,
                        1,
                        channels);

                    output += block * channels;
                    remaining -= block;
                    currentFrame += block;
                }
            }

            if (event.type == 1)
                fluid_synth_noteon(synth, 0, event.pitch, 100);
            else
                fluid_synth_noteoff(synth, 0, event.pitch);
        }

        while (currentFrame < totalFrames)
        {
            const int block =
                static_cast<int>(
                    std::min<qint64>(totalFrames - currentFrame, 8192));

            qint16 *output =
                reinterpret_cast<qint16 *>(
                    m_audioData.data() +
                    currentFrame * channels *
                        static_cast<qint64>(sizeof(qint16)));

            fluid_synth_write_s16(
                synth,
                block,
                output,
                0,
                channels,
                output,
                1,
                channels);

            currentFrame += block;
        }

        // Release every possible active note.
        for (int pitch = 0; pitch < 128; ++pitch)
            fluid_synth_noteoff(synth, 0, pitch);

        // Short fade-in/out avoids a discontinuity at the audio boundaries.
        const qint64 fadeFrames =
            std::min<qint64>(sampleRate / 100, totalFrames / 2);

        qint16 *samples =
            reinterpret_cast<qint16 *>(m_audioData.data());

        for (qint64 frame = 0; frame < fadeFrames; ++frame)
        {
            const double gain =
                static_cast<double>(frame) /
                static_cast<double>(fadeFrames);

            samples[frame * 2] =
                static_cast<qint16>(samples[frame * 2] * gain);

            samples[frame * 2 + 1] =
                static_cast<qint16>(samples[frame * 2 + 1] * gain);
        }

        for (qint64 frame = 0; frame < fadeFrames; ++frame)
        {
            const qint64 index = totalFrames - fadeFrames + frame;
            const double gain =
                1.0 -
                static_cast<double>(frame) /
                    static_cast<double>(fadeFrames);

            samples[index * 2] =
                static_cast<qint16>(samples[index * 2] * gain);

            samples[index * 2 + 1] =
                static_cast<qint16>(samples[index * 2 + 1] * gain);
        }

        fluid_synth_sfunload(synth, soundFontId, 0);
        delete_fluid_synth(synth);
        delete_fluid_settings(settings);

        m_audioFormat.setSampleRate(sampleRate);
        m_audioFormat.setChannelCount(channels);
        m_audioFormat.setSampleFormat(QAudioFormat::Int16);

        return !m_audioData.isEmpty();
    }

    void clearAudio()
    {
        if (m_audioSink)
        {
            m_audioSink->stop();
            delete m_audioSink;
            m_audioSink = nullptr;
        }

        m_audioBuffer.close();
        m_audioData.clear();
        m_playing = false;
        m_playbackPosition = 0.0;
    }

    qint64 secondsToBytes(double seconds) const
    {
        constexpr qint64 bytesPerSecond =
            44100LL * 2LL * 2LL;

        return qBound<qint64>(
            0,
            static_cast<qint64>(
                std::llround(seconds * bytesPerSecond)),
            m_audioData.size());
    }

    double bytesToSeconds(qint64 bytes) const
    {
        constexpr double bytesPerSecond =
            44100.0 * 2.0 * 2.0;

        return bytes / bytesPerSecond;
    }

private slots:
    void updatePlaybackPosition()
    {
        if (!m_audioSink || !m_playing)
            return;

        const qint64 position = m_audioBuffer.pos();
        m_playbackPosition = bytesToSeconds(position);

        if (m_playbackPosition >= m_duration)
        {
            stopPlayback();
            return;
        }

        emit playbackChanged();
    }

private:
    QString m_key = "Unknown";
    double m_duration = 0.0;
    int m_trackCount = 0;
    double m_tempo = 0.0;
    int m_totalNotes = 0;
    double m_averagePitch = 0.0;
    double m_averageDuration = 0.0;
    int m_lowestPitch = 0;
    int m_highestPitch = 0;

    QVariantList m_noteFrequency;
    QVariantList m_chordProgression;
    QVariantList m_noteTimeline;

    QString m_status = "Ready";
    std::vector<NoteInterval> m_notes;

    QAudioFormat m_audioFormat;
    QAudioSink *m_audioSink = nullptr;
    QBuffer m_audioBuffer;
    QByteArray m_audioData;
    QTimer m_playbackTimer;

    bool m_playing = false;
    double m_playbackPosition = 0.0;
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    MusicAnalyzer analyzer;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("analyzer", &analyzer);

    const QUrl url(QStringLiteral("qrc:/MusicTheoryAnalyzer/Main.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []()
        {
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}

#include "main.moc"
