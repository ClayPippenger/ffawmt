using System;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Threading.Tasks;
using FFAWMT.Services;
using System.Collections.Generic;

namespace FFAWMT
{
    public partial class MainForm : Form
    {
        private StringBuilder _consoleBuffer = new();

        public MainForm()
        {
            InitializeComponent();
            InitializeConsoleRedirect();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            try
            {
                Logger.Init(AppendLogMessage);
            }
            catch (Exception ex)
            {

                Logger.Log($"ERROR {ex.Message}");
            }
        }

        private void AppendLogMessage(string message)
        {
            if (txtConsole.InvokeRequired)
            {
                txtConsole.BeginInvoke(new Action<string>(AppendLogMessage), message);
            }
            else
            {
                txtConsole.AppendText(message + Environment.NewLine);
                txtConsole.ScrollToCaret();
            }
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            Logger.Close();
        }

        private void InitializeConsoleRedirect()
        {
            Console.SetOut(new TextBoxWriter(txtConsole, _consoleBuffer));
            Console.SetError(new TextBoxWriter(txtConsole, _consoleBuffer));
        }

        private async void btnSyncWordPress_Click(object sender, EventArgs e)
        {
            try
            {
                Logger.Prefix = "WordPress";
                Logger.Log("[▶️] Import WordPress Metadata");
                await WordPressAPIManager.SyncWordPressMetadataAsync();
                Logger.Log("[🛑] Import WordPress Metadata");

                Logger.Prefix = "Internal rules";
                Logger.Log("[▶️] Run internal rules");

                int updatedSLines = ParagraphImporter.UpdateCleanAndTextForSeparatorLines();
                if (updatedSLines < 1) Logger.Log("No Separator Lines found.");

                int updatedSeparators = ParagraphImporter.UpdateEnglishSeparatorParagraphNumber();
                if (updatedSeparators < 1) Logger.Log("No English separator paragraph number positions (~~~) needed updating.");

                int updatedCounts = ParagraphImporter.UpdateEnglishParagraphCountsInArticlesTranslations();
                if (updatedCounts < 1) Logger.Log("No English paragraph counts in Article_Translations needed updating.");

                //Logger.Log("Updating English titles for Article_Translations...");
                int updatedTitles = ParagraphImporter.UpdateEnglishTitlesInArticlesTranslations();
                if (updatedTitles < 1) Logger.Log("No English titles in Articles_Translations needed updating.");

                Logger.Log("[🛑] Run internal rules");
                Logger.Prefix = "";
            }
            catch (Exception ex)
            {
                Logger.Log("ERROR " + ex.Message);
            }
        }

        private void btnCleanParagraphs_Click(object sender, EventArgs e)
        {
            try
            {
                Logger.Prefix = "Paragraph_Cleaning_Rules";
                Logger.Log("[▶️] Process Paragraph Cleaning Rules");
                ParagraphCleaner.Run();
                Logger.Log("[🛑] Process Paragraph Cleaning Rules");
            }
            catch (Exception ex)
            {
                Logger.Log("ERROR " + ex.Message);
            }
        }

        private void btnCreateMp3_Click(object sender, EventArgs e)
        {
            try
            {
                Logger.Log("[Begin] Create English MP3s");
                Mp3Generator.Run();
                Logger.Log("[Complete] Create English MP3s");
            }
            catch (Exception ex)
            {
                Logger.Log("ERROR " + ex.Message);
            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            try
            {
                Logger.Log("### Application Exit ###");
                Application.Exit();
            }
            catch (Exception ex)
            {
                Logger.Log("ERROR " + ex.Message);
            }
        }

        private class TextBoxWriter : TextWriter
        {
            private readonly TextBox _output;
            private readonly StringBuilder _buffer;

            public TextBoxWriter(TextBox output, StringBuilder buffer)
            {
                _output = output;
                _buffer = buffer;
            }

            public override Encoding Encoding => Encoding.UTF8;

            public override void Write(string value)
            {
                _buffer.Append(value);
                _output.Invoke((MethodInvoker)(() => _output.AppendText(value)));
            }

            public override void WriteLine(string value)
            {
                _buffer.AppendLine(value);
                _output.Invoke((MethodInvoker)(() => _output.AppendText(value + Environment.NewLine)));
            }
        }
   }
}