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
                Logger.Log("[INIT] AppConfig loaded.");
                Logger.Log("FFA Translation Utility Started...");
                Logger.Log("Select an action using the buttons above.");
            }
            catch (Exception ex)
            {
                Logger.Log($"CRITICAL ERROR during startup: {ex.Message}");
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
                Logger.Log("[Action] Syncing WordPress metadata...");
                await WordPressAPIManager.SyncWordPressMetadataAsync();
                Logger.Log("[Done] Sync complete.");
            }
            catch (Exception ex)
            {
                Logger.Log("[ERROR] " + ex.Message);
            }
        }

        private void btnImportParagraphs_Click(object sender, EventArgs e)
        {
            Logger.Log("[Action] Importing article paragraphs...");
            Logger.Log("Starting paragraph import process...");

            List<int> updatedArticleIds = ParagraphImporter.ImportAll();

            if (updatedArticleIds.Count > 0)
            {
                Logger.Log($"✔️ Paragraphs updated for {updatedArticleIds.Count} article(s).");

                Logger.Log("Updating separator paragraph numbers (~~~)...");
                ParagraphImporter.UpdateSeparatorParagraphs();
                Logger.Log("✔️ Updated separator lines.");

                Logger.Log("Updating paragraph counts...");
                ParagraphImporter.UpdateParagraphCounts();
                Logger.Log("✔️ Updated paragraph counts.");

                Logger.Log("Updating translated titles...");
                ParagraphImporter.UpdateTranslatedTitles();
                Logger.Log("✔️ Updated translated titles.");
            }
            else
            {
                Logger.Log("No articles needed re-importing. Skipping post-import updates.");
            }

            Logger.Log("[Done] Paragraph import complete.");
        }


        private void btnCleanParagraphs_Click(object sender, EventArgs e)
        {
            try
            {
                Logger.Log("[Action] Cleaning article paragraphs...");
                ParagraphCleaner.Run();
                Logger.Log("[Done] Paragraph cleaning complete.");
            }
            catch (Exception ex)
            {
                Logger.Log("[ERROR] " + ex.Message);
            }
        }

        private async void btnFullReset_Click(object sender, EventArgs e)
        {
            try
            {
                Logger.Log("[Action] Performing full reset...");
                await WordPressAPIManager.SyncWordPressMetadataAsync();
                ParagraphImporter.Run();
                ParagraphCleaner.Run();
                Logger.Log("[Done] Full reset complete.");
            }
            catch (Exception ex)
            {
                Logger.Log("[ERROR] " + ex.Message);
            }
        }

        private void btnCreateMp3_Click(object sender, EventArgs e)
        {
            try
            {
                Logger.Log("[Action] Creating MP3 files for English paragraphs...");
                Mp3Generator.Run();
                Logger.Log("[Done] MP3 generation complete.");
            }
            catch (Exception ex)
            {
                Logger.Log("[ERROR] " + ex.Message);
            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            Logger.Log("Exiting application...");
            Application.Exit();
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