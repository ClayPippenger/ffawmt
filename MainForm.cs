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
                Logger.Log("### FFA Website Management Tool ###");
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
                Logger.Log("[Begin] Import WordPress Metadata");
                await WordPressAPIManager.SyncWordPressMetadataAsync();
                Logger.Log("[Complete] Import WordPress Metadata");
            }
            catch (Exception ex)
            {
                Logger.Log("[ERROR] " + ex.Message);
            }
        }

        private void btnImportParagraphs_Click(object sender, EventArgs e)
        {
            Logger.Log("[Begin] Breakout HTML Into Paragraphs");

            List<int> updatedArticleIds = ParagraphImporter.ImportAll();

            if (updatedArticleIds.Count > 0)
            {
                Logger.Log($"✔️ Paragraphs updated for {updatedArticleIds.Count} article(s).");
            }
            else
            {
                Logger.Log("No articles needed re-importing. Skipping post-import updates.");
            }

            Logger.Log("Running Base Rules...");

            int updatedSLines = ParagraphImporter.UpdateCleanAndTextForSeparatorLines();
            if (updatedSLines < 1) Logger.Log("✔️ No Separator Lines found.");

            Logger.Log("Updating English separator paragraph number positions (~~~)...");
            int updatedSeparators = ParagraphImporter.UpdateEnglishSeparatorParagraphNumber();
            Logger.Log(updatedSeparators > 0
                ? $"✔️ Updated {updatedSeparators} English separator paragraph number positions (~~~)."
                : "✔️ No English separator paragraph number positions (~~~) needed updating.");

            Logger.Log("Updating English paragraph counts for Article_Translations...");
            int updatedCounts = ParagraphImporter.UpdateEnglishParagraphCountsInArticlesTranslations();
            Logger.Log(updatedCounts > 0
                ? $"✔️ Updated {updatedCounts} English paragraph counts for Article_Translations."
                : "✔️ No English paragraph counts for Article_Translations needed updating.");

            Logger.Log("Updating English titles for Article_Translations...");
            int updatedTitles = ParagraphImporter.UpdateEnglishTitlesInArticlesTranslations();
            Logger.Log(updatedTitles > 0
                ? $"✔️ Updated {updatedTitles} English titles for Article_Translations."
                : "✔️ No English titles in Articles_Translations needed updating.");

            Logger.Log("[Complete] Breakout HTML Into Paragraphs");
        }


        private void btnCleanParagraphs_Click(object sender, EventArgs e)
        {
            try
            {
                Logger.Log("[Begin] Process Paragraph Clean Rules");
                ParagraphCleaner.Run();
                Logger.Log("[Complete] Process Paragraph Clean Rules");
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
                Logger.Log("[Begin] FIRST 3 STEPS");

                // 1
                Logger.Log("[Begin] Import WordPress Metadata");
                await WordPressAPIManager.SyncWordPressMetadataAsync();
                Logger.Log("[Complete] Import WordPress Metadata");

                // 2
                Logger.Log("[Begin] Breakout HTML Into Paragraphs");

                List<int> updatedArticleIds = ParagraphImporter.ImportAll();

                if (updatedArticleIds.Count > 0)
                {
                    Logger.Log($"✔️ Paragraphs updated for {updatedArticleIds.Count} article(s).");
                }
                else
                {
                    Logger.Log("No articles needed re-importing. Skipping post-import updates.");
                }

                Logger.Log("Running Base Rules...");

                int updatedSLines = ParagraphImporter.UpdateCleanAndTextForSeparatorLines();
                if (updatedSLines < 1) Logger.Log("✔️ No Separator Lines found.");

                Logger.Log("Updating English separator paragraph number positions (~~~)...");
                int updatedSeparators = ParagraphImporter.UpdateEnglishSeparatorParagraphNumber();
                Logger.Log(updatedSeparators > 0
                    ? $"✔️ Updated {updatedSeparators} English separator paragraph number positions (~~~)."
                    : "✔️ No English separator paragraph number positions (~~~) needed updating.");

                Logger.Log("Updating English paragraph counts for Article_Translations...");
                int updatedCounts = ParagraphImporter.UpdateEnglishParagraphCountsInArticlesTranslations();
                Logger.Log(updatedCounts > 0
                    ? $"✔️ Updated {updatedCounts} English paragraph counts for Article_Translations."
                    : "✔️ No English paragraph counts for Article_Translations needed updating.");

                Logger.Log("Updating English titles for Article_Translations...");
                int updatedTitles = ParagraphImporter.UpdateEnglishTitlesInArticlesTranslations();
                Logger.Log(updatedTitles > 0
                    ? $"✔️ Updated {updatedTitles} English titles for Article_Translations."
                    : "✔️ No English titles in Articles_Translations needed updating.");
                
                Logger.Log("[Complete] Breakout HTML Into Paragraphs");

                // C
                Logger.Log("[Begin] Process Paragraph Clean Rules");
                ParagraphCleaner.Run();
                Logger.Log("[Complete] Process Paragraph Clean Rules");

                Logger.Log("[Complete] FIRST 3 STEPS");
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
                Logger.Log("[Begin] Create English MP3s");
                Mp3Generator.Run();
                Logger.Log("[Complete] Create English MP3s");
            }
            catch (Exception ex)
            {
                Logger.Log("[ERROR] " + ex.Message);
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
                Logger.Log("[ERROR] " + ex.Message);
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