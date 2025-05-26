namespace FFAWMT
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        private System.Windows.Forms.TextBox txtConsole;
        private System.Windows.Forms.FlowLayoutPanel panelButtons;

        private System.Windows.Forms.Button btnSyncWordPress;
        private System.Windows.Forms.Button btnImportParagraphs;
        private System.Windows.Forms.Button btnCleanParagraphs;
        private System.Windows.Forms.Button btnFullReset;
        private System.Windows.Forms.Button btnCreateMp3;
        private System.Windows.Forms.Button btnExit;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
                components.Dispose();
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        private void InitializeComponent()
        {
            this.txtConsole = new System.Windows.Forms.TextBox();
            this.panelButtons = new System.Windows.Forms.FlowLayoutPanel();
            this.btnSyncWordPress = new System.Windows.Forms.Button();
            this.btnImportParagraphs = new System.Windows.Forms.Button();
            this.btnCleanParagraphs = new System.Windows.Forms.Button();
            this.btnFullReset = new System.Windows.Forms.Button();
            this.btnCreateMp3 = new System.Windows.Forms.Button();
            this.btnExit = new System.Windows.Forms.Button();

            // 
            // MainForm
            // 
            this.Text = "FFA Translation Utility";
            this.ClientSize = new System.Drawing.Size(1000, 600);
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Load += new System.EventHandler(this.MainForm_Load);

            // 
            // panelButtons
            // 
            this.panelButtons.Dock = System.Windows.Forms.DockStyle.Top;
            this.panelButtons.Height = 60;
            this.panelButtons.AutoSize = true;
            this.panelButtons.FlowDirection = System.Windows.Forms.FlowDirection.LeftToRight;
            this.panelButtons.WrapContents = false;
            this.panelButtons.Padding = new System.Windows.Forms.Padding(5);

            // 
            // txtConsole
            // 
            this.txtConsole.Dock = System.Windows.Forms.DockStyle.Fill;
            this.txtConsole.Multiline = true;
            this.txtConsole.ReadOnly = true;
            this.txtConsole.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.txtConsole.Font = new System.Drawing.Font("Consolas", 10F);
            this.txtConsole.BackColor = System.Drawing.Color.Black;
            this.txtConsole.ForeColor = System.Drawing.Color.LightGreen;
            this.txtConsole.WordWrap = false;

            // 
            // Buttons
            // 
            this.btnSyncWordPress.Text = "1. Sync WordPress Metadata";
            this.btnSyncWordPress.Click += new System.EventHandler(this.btnSyncWordPress_Click);

            this.btnImportParagraphs.Text = "2. Import Article Paragraphs";
            this.btnImportParagraphs.Click += new System.EventHandler(this.btnImportParagraphs_Click);

            this.btnCleanParagraphs.Text = "C. Clean Paragraphs";
            this.btnCleanParagraphs.Click += new System.EventHandler(this.btnCleanParagraphs_Click);

            this.btnFullReset.Text = "3. Full Reset (1→2→C)";
            this.btnFullReset.Click += new System.EventHandler(this.btnFullReset_Click);

            this.btnCreateMp3.Text = "4. Create MP3s (English)";
            this.btnCreateMp3.Click += new System.EventHandler(this.btnCreateMp3_Click);

            this.btnExit.Text = "X. Exit";
            this.btnExit.Click += new System.EventHandler(this.btnExit_Click);

            // 
            // Add controls to panel
            // 
            this.panelButtons.Controls.Add(this.btnSyncWordPress);
            this.panelButtons.Controls.Add(this.btnImportParagraphs);
            this.panelButtons.Controls.Add(this.btnCleanParagraphs);
            this.panelButtons.Controls.Add(this.btnFullReset);
            this.panelButtons.Controls.Add(this.btnCreateMp3);
            this.panelButtons.Controls.Add(this.btnExit);

            // 
            // Add to MainForm
            // 
            this.Controls.Add(this.txtConsole);
            this.Controls.Add(this.panelButtons);
        }

        #endregion
    }
}
