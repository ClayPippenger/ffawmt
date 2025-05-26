using System;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Threading.Tasks;
using FFAWMT.Services;

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
                AppConfig.Load();
                Log("[INIT] AppConfig loaded.");
                Log("FFA Translation Utility Started...");
                Log("Select an action using the buttons above.");
            }
            catch (Exception ex)
            {
                Log($"CRITICAL ERROR during startup: {ex.Message}");
            }
        }

        private void InitializeConsoleRedirect()
        {
            Console.SetOut(new TextBoxWriter(txtConsole, _consoleBuffer));
            Console.SetError(new TextBoxWriter(txtConsole, _consoleBuffer));
        }

        private void Log(string message)
        {
            txtConsole.AppendText(message + Environment.NewLine);
        }

        private async void btnSyncWordPress_Click(object sender, EventArgs e)
        {
            try
            {
                Log("[Action] Syncing WordPress metadata...");
                await WordPressAPIManager.SyncWordPressMetadataAsync();
                Log("[Done] Sync complete.");
            }
            catch (Exception ex)
            {
                Log("[ERROR] " + ex.Message);
            }
        }

        private void btnImportParagraphs_Click(object sender, EventArgs e)
        {
            try
            {
                Log("[Action] Importing article paragraphs...");
                ParagraphImporter.Run();
                Log("[Done] Paragraph import complete.");
            }
            catch (Exception ex)
            {
                Log("[ERROR] " + ex.Message);
            }
        }

        private void btnCleanParagraphs_Click(object sender, EventArgs e)
        {
            try
            {
                Log("[Action] Cleaning article paragraphs...");
                ParagraphCleaner.Run();
                Log("[Done] Paragraph cleaning complete.");
            }
            catch (Exception ex)
            {
                Log("[ERROR] " + ex.Message);
            }
        }

        private async void btnFullReset_Click(object sender, EventArgs e)
        {
            try
            {
                Log("[Action] Performing full reset...");
                await WordPressAPIManager.SyncWordPressMetadataAsync();
                ParagraphImporter.Run();
                ParagraphCleaner.Run();
                Log("[Done] Full reset complete.");
            }
            catch (Exception ex)
            {
                Log("[ERROR] " + ex.Message);
            }
        }

        private void btnCreateMp3_Click(object sender, EventArgs e)
        {
            try
            {
                Log("[Action] Creating MP3 files for English paragraphs...");
                Mp3Generator.Run();
                Log("[Done] MP3 generation complete.");
            }
            catch (Exception ex)
            {
                Log("[ERROR] " + ex.Message);
            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            Log("Exiting application...");
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