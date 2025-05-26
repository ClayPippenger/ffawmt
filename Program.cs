using System;
using System.Windows.Forms;

namespace FFAWMT
{
    internal static class Program
    {
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            AppConfig.Load(); // .NET 6+ WinForms bootstrapper
            Application.Run(new MainForm());
        }
    }
}
