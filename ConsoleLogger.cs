using FFAWMT;
using System;
using System.IO;
using System.Text;

public static class ConsoleLogger
{
    private static StreamWriter _logWriter;

    public static void Init()
    {
        string logDir = AppConfig.Current.AppLogPath;
        Directory.CreateDirectory(logDir);
        string timestamp = DateTime.Now.ToString("yyyy-MM-dd_HHmmss_fff");
        string logPath = Path.Combine(logDir, $"FFA_{timestamp}.txt");

        _logWriter = new StreamWriter(logPath) { AutoFlush = true };
        Console.SetOut(new DualWriter(Console.Out, _logWriter));
    }

    public static void Shutdown()
    {
        _logWriter?.Flush();
        _logWriter?.Close();
    }

    private class DualWriter : TextWriter
    {
        private readonly TextWriter _console;
        private readonly TextWriter _log;

        public DualWriter(TextWriter console, TextWriter log)
        {
            _console = console;
            _log = log;
        }

        public override Encoding Encoding => _console.Encoding;

        public override void WriteLine(string value)
        {
            _console.WriteLine(value);
            _log.WriteLine(value);
        }

        public override void Write(string value)
        {
            _console.Write(value);
            _log.Write(value);
        }
    }
}
