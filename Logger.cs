using System.IO;
using System;

public static class Logger
{
    private static readonly object LockObj = new();

    public static string Prefix { get; set; } = ""; // New prefix property
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

        Prefix = "";
        Log("Log Init");
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
            lock (LockObj)
            {
                string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                string output = string.IsNullOrEmpty(Prefix)
                    ? $"{timestamp} {message}"
                    : $"{timestamp} [{Prefix}] {message}";

                _logFile?.WriteLine(output);
                _logToUI?.Invoke(output);
            }
            string timestamped = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} {message}";
            
        }
        catch { /* optional: silent fail */ }
    }

    public static void Close()
    {
        Prefix = "";
        Log("Log Close");
        _logFile?.Close();
    }
}
