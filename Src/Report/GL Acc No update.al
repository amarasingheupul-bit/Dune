report 50106 "G/L Account Update"
{
    Caption = 'G/L Account Update';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    Permissions = tabledata "G/L Entry" = RIMD;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Filters)
                {
                    Caption = 'Account Remap Settings';

                    field(Step1FromField; Step1From)
                    {
                        ApplicationArea = All;
                        Caption = 'Step 1 - From Account (Temp Park)';
                        ToolTip = 'This account will be temporarily renamed first. e.g. 155140';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GLAccount: Record "G/L Account";
                        begin
                            if Page.RunModal(Page::"G/L Account List", GLAccount) = Action::LookupOK then begin
                                Step1From := GLAccount."No.";
                                Text := Step1From;
                                exit(true);
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            ValidateFields();
                        end;
                    }

                    field(Step1ToField; Step1To)
                    {
                        ApplicationArea = All;
                        Caption = 'Step 1 - Temp Account No.';
                        ToolTip = 'Temporary placeholder. e.g. 1234. Must not exist in G/L Entries.';

                        trigger OnValidate()
                        begin
                            ValidateFields();
                        end;
                    }

                    field(Step2FromField; Step2From)
                    {
                        ApplicationArea = All;
                        Caption = 'Step 2 - From Account';
                        ToolTip = 'This account will be renamed. e.g. 254120';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GLAccount: Record "G/L Account";
                        begin
                            if Page.RunModal(Page::"G/L Account List", GLAccount) = Action::LookupOK then begin
                                Step2From := GLAccount."No.";
                                Text := Step2From;
                                exit(true);
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            ValidateFields();
                        end;
                    }

                    field(Step2ToField; Step2To)
                    {
                        ApplicationArea = All;
                        Caption = 'Step 2 - To Account';
                        ToolTip = 'Step 2 From account will be renamed to this. e.g. 155140';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GLAccount: Record "G/L Account";
                        begin
                            if Page.RunModal(Page::"G/L Account List", GLAccount) = Action::LookupOK then begin
                                Step2To := GLAccount."No.";
                                Text := Step2To;
                                exit(true);
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            ValidateFields();
                        end;
                    }

                    field(Step3ToField; Step3To)
                    {
                        ApplicationArea = All;
                        Caption = 'Step 3 - Final Account (Resolve Temp)';
                        ToolTip = 'The temp account will be finally renamed to this. e.g. 254120';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GLAccount: Record "G/L Account";
                        begin
                            if Page.RunModal(Page::"G/L Account List", GLAccount) = Action::LookupOK then begin
                                Step3To := GLAccount."No.";
                                Text := Step3To;
                                exit(true);
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            ValidateFields();
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            Step1From := '155140';
            Step1To := '1234';
            Step2From := '254120';
            Step2To := '155140';
            Step3To := '254120';
        end;
    }

    trigger OnPreReport()
    begin
        ValidateFields();
        RunRemap();
    end;

    local procedure ValidateFields()
    begin
        if Step1From = '' then Error('Step 1 From Account cannot be blank.');
        if Step1To = '' then Error('Step 1 Temp Account cannot be blank.');
        if Step2From = '' then Error('Step 2 From Account cannot be blank.');
        if Step2To = '' then Error('Step 2 To Account cannot be blank.');
        if Step3To = '' then Error('Step 3 Final Account cannot be blank.');

        if Step1From = Step1To then Error('Step 1 From and Temp Account cannot be the same.');
        if Step1From = Step2From then Error('Step 1 From and Step 2 From cannot be the same.');
        if Step1To = Step2From then Error('Temp Account and Step 2 From cannot be the same.');
        if Step2To = Step3To then Error('Step 2 To and Step 3 Final cannot be the same.');

        CheckTempNotExists();
    end;

    local procedure CheckTempNotExists()
    var
        GLEntry: Record "G/L Entry";
    begin
        // Check temp does not exist in G/L Account No.
        GLEntry.Reset();
        GLEntry.SetRange("G/L Account No.", Step1To);
        if not GLEntry.IsEmpty() then
            Error(
                'Temp Account No. "%1" already has G/L Entries in G/L Account No.\n' +
                'Please choose a different Temp Account No.',
                Step1To);

        // Check temp does not exist in Bal. Account No.
        GLEntry.Reset();
        GLEntry.SetRange("Bal. Account No.", Step1To);
        if not GLEntry.IsEmpty() then
            Error(
                'Temp Account No. "%1" already has G/L Entries in Bal. Account No.\n' +
                'Please choose a different Temp Account No.',
                Step1To);
    end;

    local procedure RunRemap()
    var
        GLEntry: Record "G/L Entry";
        GLAccPass1: Integer;
        GLAccPass2: Integer;
        GLAccPass3: Integer;
        BalAccPass1: Integer;
        BalAccPass2: Integer;
        BalAccPass3: Integer;
    begin
        if not Confirm(
            'WARNING: This will permanently remap G/L Account No. AND Bal. Account No.:\n\n' +
            '  Step 1: %1  →  %2  (temp park)\n' +
            '  Step 2: %3  →  %4\n' +
            '  Step 3: %2  →  %5  (resolve temp)\n\n' +
            'This CANNOT be undone. Continue?',
            false, Step1From, Step1To, Step2From, Step2To, Step3To)
        then
            Error('Cancelled. No changes made.');

        // ===============================================================
        // G/L ACCOUNT NO. — 3 PASSES
        // ===============================================================

        // PASS 1: G/L Account No. — Step1From (155140) → Step1To (1234)
        GLEntry.Reset();
        GLEntry.SetRange("G/L Account No.", Step1From);
        if GLEntry.FindSet(true) then
            repeat
                GLEntry."G/L Account No." := Step1To;
                GLEntry.Modify(false);
                GLAccPass1 += 1;
            until GLEntry.Next() = 0;

        // PASS 2: G/L Account No. — Step2From (254120) → Step2To (155140)
        GLEntry.Reset();
        GLEntry.SetRange("G/L Account No.", Step2From);
        if GLEntry.FindSet(true) then
            repeat
                GLEntry."G/L Account No." := Step2To;
                GLEntry.Modify(false);
                GLAccPass2 += 1;
            until GLEntry.Next() = 0;

        // PASS 3: G/L Account No. — Step1To (1234) → Step3To (254120)
        GLEntry.Reset();
        GLEntry.SetRange("G/L Account No.", Step1To);
        if GLEntry.FindSet(true) then
            repeat
                GLEntry."G/L Account No." := Step3To;
                GLEntry.Modify(false);
                GLAccPass3 += 1;
            until GLEntry.Next() = 0;

        // ===============================================================
        // BAL. ACCOUNT NO. — 3 PASSES
        // ===============================================================

        // PASS 1: Bal. Account No. — Step1From (155140) → Step1To (1234)
        GLEntry.Reset();
        GLEntry.SetRange("Bal. Account No.", Step1From);
        if GLEntry.FindSet(true) then
            repeat
                GLEntry."Bal. Account No." := Step1To;
                GLEntry.Modify(false);
                BalAccPass1 += 1;
            until GLEntry.Next() = 0;

        // PASS 2: Bal. Account No. — Step2From (254120) → Step2To (155140)
        GLEntry.Reset();
        GLEntry.SetRange("Bal. Account No.", Step2From);
        if GLEntry.FindSet(true) then
            repeat
                GLEntry."Bal. Account No." := Step2To;
                GLEntry.Modify(false);
                BalAccPass2 += 1;
            until GLEntry.Next() = 0;

        // PASS 3: Bal. Account No. — Step1To (1234) → Step3To (254120)
        GLEntry.Reset();
        GLEntry.SetRange("Bal. Account No.", Step1To);
        if GLEntry.FindSet(true) then
            repeat
                GLEntry."Bal. Account No." := Step3To;
                GLEntry.Modify(false);
                BalAccPass3 += 1;
            until GLEntry.Next() = 0;

        // ===============================================================
        // SAFETY CHECK — temp must be fully cleared on both fields
        // ===============================================================
        if GLAccPass1 <> GLAccPass3 then
            Error(
                'CRITICAL: %1 entries still stuck as "%2" in G/L Account No.!\n' +
                'Pass 1 parked  : %3\n' +
                'Pass 3 resolved: %4\n\n' +
                'Manually check G/L Entries with G/L Account No. = "%2".',
                GLAccPass1 - GLAccPass3, Step1To, GLAccPass1, GLAccPass3);

        if BalAccPass1 <> BalAccPass3 then
            Error(
                'CRITICAL: %1 entries still stuck as "%2" in Bal. Account No.!\n' +
                'Pass 1 parked  : %3\n' +
                'Pass 3 resolved: %4\n\n' +
                'Manually check G/L Entries with Bal. Account No. = "%2".',
                BalAccPass1 - BalAccPass3, Step1To, BalAccPass1, BalAccPass3);

        // Success
        Message(
            'Remap completed successfully!\n\n' +
            '--- G/L Account No. ---\n' +
            '  %1 → %2 : %3 entries\n' +
            '  %4 → %5 : %6 entries\n\n' +
            '--- Bal. Account No. ---\n' +
            '  %1 → %2 : %7 entries\n' +
            '  %4 → %5 : %8 entries\n\n' +
            'Total updated: %9 entries.',
            Step1From, Step3To, GLAccPass1,
            Step2From, Step2To, GLAccPass2,
            BalAccPass1,
            BalAccPass2,
            GLAccPass1 + GLAccPass2 + BalAccPass1 + BalAccPass2);
    end;

    var
        Step1From: Code[20];  // 155140 - account to park temporarily
        Step1To: Code[20];  // 1234   - temp placeholder
        Step2From: Code[20];  // 254120 - account to rename
        Step2To: Code[20];  // 155140 - rename 254120 to this
        Step3To: Code[20];  // 254120 - resolve temp to this final value
}