using System.IO;
using System;

public static class Logger
{
    private static StreamWriter _logFile;
    private static Action<string> _logToUI;

    public static void Init(string filePath, Action<string> uiLogger = null)
    {
        if (_logFile == null)
        {
            _logFile = new StreamWriter(filePath, append: true) { AutoFlush = true };
        }

        if (uiLogger != null)
        {
            _logToUI = uiLogger;
        }

        Log("Logger initialized.");
    }

    // Overload for updating just the UI logger
    public static void Init(Action<string> uiLogger)
    {
        Init(null, uiLogger);
    }

    public static void Log(string message)
    {
        try
        {
            string timestamped = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} {message}";
            _logFile?.WriteLine(timestamped);
            _logToUI?.Invoke(timestamped);
        }
        catch { /* optional: silent fail */ }
    }

    public static void Close()
    {
        Log("Logger closing.");
        _logFile?.Close();
    }
}
