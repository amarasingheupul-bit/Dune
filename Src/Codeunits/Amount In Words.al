codeunit 50110 "Amount In Words"
{
    local procedure AddToNoText(var NoText: array[2] of Text[80]; var NoTextIndex: Integer; var PrintExponent: Boolean; AddText: Text[30])
    begin
        PrintExponent := true;

        while StrLen(NoText[NoTextIndex] + ' ' + AddText) > MaxStrLen(NoText[1]) do begin
            NoTextIndex := NoTextIndex + 1;
            if NoTextIndex > ArrayLen(NoText) then
                Error(Text029, AddText);
        end;

        NoText[NoTextIndex] := DelChr(NoText[NoTextIndex] + ' ' + AddText, '<');
    end;

    procedure FormatNoTextV2(var NoText: array[3] of Text[50]; No: Decimal; CurrencyCode: Code[10]; IsUpperCase: Boolean; StartStar: Boolean; EndStar: Boolean)
    var
        PrintExponent: Boolean;
        Ones: Integer;
        Tens: Integer;
        Hundreds: Integer;
        Exponent: Integer;
        NoTextIndex: Integer;
        DecimalPosition: Decimal;
        Cents_: Integer;
        Text026: Label 'Zero';
        Text027: Label 'Hundred';
        Text028: Label 'And';
        Text029: Label '%1 results in a written number that is too long.';
        Text030: Label ' is already applied to %1 %2 for customer %3.';
        Text031: Label ' is already applied to %1 %2 for vendor %3.';
        Text032: Label 'One';
        Text033: Label 'Two';
        Text034: Label 'Three';
        Text035: Label 'Four';
        Text036: Label 'Five';
        Text037: Label 'Six';
        Text038: Label 'Seven';
        Text039: Label 'Eight';
        Text040: Label 'Nine';
        Text041: Label 'Ten';
        Text042: Label 'Eleven';
        Text043: Label 'Twelve';
        Text044: Label 'Thirteen';
        Text045: Label 'Fourteen';
        Text046: Label 'Fifteen';
        Text047: Label 'Sixteen';
        Text048: Label 'Seventeen';
        Text049: Label 'Eighteen';
        Text050: Label 'Nineteen';
        Text051: Label 'Twenty';
        Text052: Label 'Thirty';
        Text053: Label 'Forty';
        Text054: Label 'Fifty';
        Text055: Label 'Sixty';
        Text056: Label 'Seventy';
        Text057: Label 'Eighty';
        Text058: Label 'Ninety';
        Text059: Label 'Thousand';
        Text060: Label 'Million';
        Text061: Label 'Billion';
        OnesText: array[20] of Text[30];
        TensText: array[10] of Text[30];
        ExponentText: array[5] of Text[30];
        //DescriptionLine: array[3] of Text[80];
        TensDec: Integer;
        OnesDec: Integer;
        CentsText: Text;
        //Text062: Label 'Cents Only**';
        Text062: Text[20];
        TextEmpty: Label '';
        TextStarSign: Label '**';
        ZeroText: Text;
        HundredText: Text;
        AndText: Text;
        CurrNameText: Text;
    begin
        /// <summary>
        /// This function converts a number to text format.
        /// This funtion use "AddToNoText" and "GetAmtDecimalPosition" local functions.
        ///
        /// </summary>
        /// <param name="NoText">Text(80) array length of 3 which returns the text</param>
        /// <param name="No">Amount or the number needs to be converted</param>
        /// <param name="CurrencyCode">Currency Code if any, if not keep it blank</param>
        /// <param name="IsUpperCase">if "TRUE" text will return in UPPERCASE, if "FALSE" first letter of each word in UPPERCASE</param>
        /// <param name="StartStar">if "TRUE", "***" will print at the begin</param>
        /// <param name="EndStar">if "TRUE", "***" will print at the end</param>
        /// <returns></returns>

        // InitTextVariable --- START
        if IsUpperCase then begin
            OnesText[1] := UpperCase(Text032);
            OnesText[2] := UpperCase(Text033);
            OnesText[3] := UpperCase(Text034);
            OnesText[4] := UpperCase(Text035);
            OnesText[5] := UpperCase(Text036);
            OnesText[6] := UpperCase(Text037);
            OnesText[7] := UpperCase(Text038);
            OnesText[8] := UpperCase(Text039);
            OnesText[9] := UpperCase(Text040);
            OnesText[10] := UpperCase(Text041);
            OnesText[11] := UpperCase(Text042);
            OnesText[12] := UpperCase(Text043);
            OnesText[13] := UpperCase(Text044);
            OnesText[14] := UpperCase(Text045);
            OnesText[15] := UpperCase(Text046);
            OnesText[16] := UpperCase(Text047);
            OnesText[17] := UpperCase(Text048);
            OnesText[18] := UpperCase(Text049);
            OnesText[19] := UpperCase(Text050);

            TensText[1] := TextEmpty;
            TensText[2] := UpperCase(Text051);
            TensText[3] := UpperCase(Text052);
            TensText[4] := UpperCase(Text053);
            TensText[5] := UpperCase(Text054);
            TensText[6] := UpperCase(Text055);
            TensText[7] := UpperCase(Text056);
            TensText[8] := UpperCase(Text057);
            TensText[9] := UpperCase(Text058);

            ExponentText[1] := TextEmpty;
            ExponentText[2] := UpperCase(Text059);
            ExponentText[3] := UpperCase(Text060);
            ExponentText[4] := UpperCase(Text061);

            GLSetup.Get;
            if CurrencyCode = '' then begin
                //Text062 := GLSetup.LCYCentsNameSqBase + ' Only**';
                CurrNameText := GLSetup."Local Currency Description";
            end
            else begin
                Currency.get(CurrencyCode);
                // Text062 := ' ' + Currency.CurrencyCentsNameSqBase + ' Only**';
                // CurrNameText := Currency.curr;
            end;
            CentsText := UpperCase(Text062);
            ZeroText := UpperCase(Text026);
            HundredText := UpperCase(Text027);
            AndText := UpperCase(Text028);
        end else begin
            OnesText[1] := Text032;
            OnesText[2] := Text033;
            OnesText[3] := Text034;
            OnesText[4] := Text035;
            OnesText[5] := Text036;
            OnesText[6] := Text037;
            OnesText[7] := Text038;
            OnesText[8] := Text039;
            OnesText[9] := Text040;
            OnesText[10] := Text041;
            OnesText[11] := Text042;
            OnesText[12] := Text043;
            OnesText[13] := Text044;
            OnesText[14] := Text045;
            OnesText[15] := Text046;
            OnesText[16] := Text047;
            OnesText[17] := Text048;
            OnesText[18] := Text049;
            OnesText[19] := Text050;

            TensText[1] := TextEmpty;
            TensText[2] := Text051;
            TensText[3] := Text052;
            TensText[4] := Text053;
            TensText[5] := Text054;
            TensText[6] := Text055;
            TensText[7] := Text056;
            TensText[8] := Text057;
            TensText[9] := Text058;

            ExponentText[1] := TextEmpty;
            ExponentText[2] := Text059;
            ExponentText[3] := Text060;
            ExponentText[4] := Text061;

            GLSetup.Get;
            // if CurrencyCode = '' then begin
            //     Text062 := GLSetup.LCYCentsNameSqBase + ' Only**';
            //     CurrNameText := GLSetup.LCYNameSqBase;
            // end
            // else begin
            //     Currency.get(CurrencyCode);
            //     Text062 := ' ' + Currency.CurrencyCentsNameSqBase + ' Only**';
            //     CurrNameText := Currency.CurrencyNameSqBase;
            // end;

            CentsText := Text062;
            ZeroText := Text026;
            HundredText := Text027;
            AndText := Text028;
        end;

        Clear(NoText);
        NoTextIndex := 1;

        if StartStar then
            NoText[1] := TextStarSign
        else
            NoText[1] := TextEmpty;

        if No < 1 then
            AddToNoText(NoText, NoTextIndex, PrintExponent, ZeroText)
        else
            for Exponent := 4 downto 1 do begin
                PrintExponent := false;
                Ones := No div Power(1000, Exponent - 1);
                Hundreds := Ones div 100;
                Tens := (Ones mod 100) div 10;
                Ones := Ones mod 10;
                if Hundreds > 0 then begin
                    AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Hundreds]);
                    AddToNoText(NoText, NoTextIndex, PrintExponent, HundredText);
                end;
                if Tens >= 2 then begin
                    AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[Tens]);
                    if Ones > 0 then
                        AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Ones]);
                end else
                    if (Tens * 10 + Ones) > 0 then
                        AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[Tens * 10 + Ones]);
                if PrintExponent and (Exponent > 1) then
                    AddToNoText(NoText, NoTextIndex, PrintExponent, ExponentText[Exponent]);
                No := No - (Hundreds * 100 + Tens * 10 + Ones) * Power(1000, Exponent - 1);
            end;

        AddToNoText(NoText, NoTextIndex, PrintExponent, CurrNameText);
        //AddToNoText(NoText, NoTextIndex, PrintExponent, AndText);
        DecimalPosition := GetAmtDecimalPositionV2(CurrencyCode);

        // --- Display Cents ----------------------------------
        TensDec := ((No * 100) mod 100) div 10;
        OnesDec := (No * 100) mod 10;

        if TensDec + OnesDec = 0 then
            AddToNoText(NoText, NoTextIndex, PrintExponent, 'Only')
        else begin
            if TensDec >= 2 then begin
                AddToNoText(NoText, NoTextIndex, PrintExponent, AndText);
                AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[TensDec]);
                if OnesDec > 0 then
                    AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[OnesDec] + ' Only')
                else
                    AddToNoText(NoText, NoTextIndex, PrintExponent, TensText[TensDec] + ' Only');
            end else
                if (TensDec * 10 + OnesDec) > 0 then begin
                    AddToNoText(NoText, NoTextIndex, PrintExponent, AndText);
                    AddToNoText(NoText, NoTextIndex, PrintExponent, OnesText[TensDec * 10 + OnesDec] + 'Only');
                end;
            if EndStar then
                AddToNoText(NoText, NoTextIndex, PrintExponent, CentsText + TextEmpty + TextStarSign)
            else
                AddToNoText(NoText, NoTextIndex, PrintExponent, CentsText);
        end;
    end;

    local procedure GetAmtDecimalPositionV2(CurrCode: Code[10]): Decimal
    var
        Currency: Record Currency;
    begin
        /// <summary>
        /// This function used to get the decimal points according to currency code.
        /// Calles inside the "FormatNoText" Function.
        /// </summary>

        if CurrCode = '' then
            Currency.InitRoundingPrecision
        else begin
            Currency.Get(CurrCode);
            Currency.TestField("Amount Rounding Precision");
        end;
        exit(1 / Currency."Amount Rounding Precision");
    end;

    var
        Text029: Label '%1 results in a written number that is too long.';
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
}