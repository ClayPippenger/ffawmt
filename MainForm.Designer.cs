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
            txtConsole = new System.Windows.Forms.TextBox();
            panelButtons = new System.Windows.Forms.FlowLayoutPanel();
            btnSyncWordPress = new System.Windows.Forms.Button();
            btnImportParagraphs = new System.Windows.Forms.Button();
            btnCleanParagraphs = new System.Windows.Forms.Button();
            btnFullReset = new System.Windows.Forms.Button();
            btnCreateMp3 = new System.Windows.Forms.Button();
            btnExit = new System.Windows.Forms.Button();
            panelButtons.SuspendLayout();
            SuspendLayout();
            // 
            // txtConsole
            // 
            txtConsole.BackColor = System.Drawing.Color.Black;
            txtConsole.Dock = System.Windows.Forms.DockStyle.Fill;
            txtConsole.Font = new System.Drawing.Font("Consolas", 10F);
            txtConsole.ForeColor = System.Drawing.Color.LightGreen;
            txtConsole.Location = new System.Drawing.Point(0, 39);
            txtConsole.Multiline = true;
            txtConsole.Name = "txtConsole";
            txtConsole.ReadOnly = true;
            txtConsole.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            txtConsole.Size = new System.Drawing.Size(1000, 561);
            txtConsole.TabIndex = 0;
            txtConsole.WordWrap = false;
            // 
            // panelButtons
            // 
            panelButtons.AutoSize = true;
            panelButtons.Controls.Add(btnSyncWordPress);
            panelButtons.Controls.Add(btnImportParagraphs);
            panelButtons.Controls.Add(btnCleanParagraphs);
            panelButtons.Controls.Add(btnFullReset);
            panelButtons.Controls.Add(btnCreateMp3);
            panelButtons.Controls.Add(btnExit);
            panelButtons.Dock = System.Windows.Forms.DockStyle.Top;
            panelButtons.Location = new System.Drawing.Point(0, 0);
            panelButtons.Name = "panelButtons";
            panelButtons.Padding = new System.Windows.Forms.Padding(5);
            panelButtons.Size = new System.Drawing.Size(1000, 39);
            panelButtons.TabIndex = 1;
            panelButtons.WrapContents = false;
            // 
            // btnSyncWordPress
            // 
            btnSyncWordPress.Location = new System.Drawing.Point(8, 8);
            btnSyncWordPress.Name = "btnSyncWordPress";
            btnSyncWordPress.Size = new System.Drawing.Size(196, 23);
            btnSyncWordPress.TabIndex = 0;
            btnSyncWordPress.Text = "Import WordPress Metadata";
            btnSyncWordPress.Click += btnSyncWordPress_Click;
            // 
            // btnImportParagraphs
            // 
            btnImportParagraphs.Location = new System.Drawing.Point(210, 8);
            btnImportParagraphs.Name = "btnImportParagraphs";
            btnImportParagraphs.Size = new System.Drawing.Size(227, 23);
            btnImportParagraphs.TabIndex = 1;
            btnImportParagraphs.Text = "Breakout HTML Into Paragraphs";
            btnImportParagraphs.Click += btnImportParagraphs_Click;
            // 
            // btnCleanParagraphs
            // 
            btnCleanParagraphs.Location = new System.Drawing.Point(443, 8);
            btnCleanParagraphs.Name = "btnCleanParagraphs";
            btnCleanParagraphs.Size = new System.Drawing.Size(75, 23);
            btnCleanParagraphs.TabIndex = 2;
            btnCleanParagraphs.Text = "C. Clean Paragraphs";
            btnCleanParagraphs.Click += btnCleanParagraphs_Click;
            // 
            // btnFullReset
            // 
            btnFullReset.Location = new System.Drawing.Point(524, 8);
            btnFullReset.Name = "btnFullReset";
            btnFullReset.Size = new System.Drawing.Size(75, 23);
            btnFullReset.TabIndex = 3;
            btnFullReset.Text = "3. Full Reset (1→2→C)";
            btnFullReset.Click += btnFullReset_Click;
            // 
            // btnCreateMp3
            // 
            btnCreateMp3.Location = new System.Drawing.Point(605, 8);
            btnCreateMp3.Name = "btnCreateMp3";
            btnCreateMp3.Size = new System.Drawing.Size(75, 23);
            btnCreateMp3.TabIndex = 4;
            btnCreateMp3.Text = "4. Create MP3s (English)";
            btnCreateMp3.Click += btnCreateMp3_Click;
            // 
            // btnExit
            // 
            btnExit.Location = new System.Drawing.Point(686, 8);
            btnExit.Name = "btnExit";
            btnExit.Size = new System.Drawing.Size(75, 23);
            btnExit.TabIndex = 5;
            btnExit.Text = "X. Exit";
            btnExit.Click += btnExit_Click;
            // 
            // MainForm
            // 
            ClientSize = new System.Drawing.Size(1000, 600);
            Controls.Add(txtConsole);
            Controls.Add(panelButtons);
            Name = "MainForm";
            StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            Text = "FFA Translation Utility";
            Load += MainForm_Load;
            panelButtons.ResumeLayout(false);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion
    }
}
