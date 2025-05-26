using FFAWMT;
using System;
using System.Windows.Forms;

static class Program
{
    [STAThread]
    static void Main()
    {
        // Step 1: Load configuration first
        AppConfig.Load();

        // Step 2: THEN use AppLogPath
        string logPath = $@"{AppConfig.Current.AppLogPath}FFA_{DateTime.Now:yyyy-MM-dd_HHmmss}.txt";
        Logger.Init(logPath);

        // Step 3: Add global exception handlers
        Application.ThreadException += (sender, args) =>
        {
            Logger.Log("Unhandled thread exception: " + args.Exception);
        };
        AppDomain.CurrentDomain.UnhandledException += (sender, args) =>
        {
            Logger.Log("Fatal exception: " + args.ExceptionObject);
            Logger.Close();
        };

        // Step 4: Launch UI
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        Application.Run(new MainForm());
    }

}
