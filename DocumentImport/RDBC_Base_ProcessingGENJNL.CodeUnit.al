codeunit 85150 "RDBC_Base_GenJournalProcessor"
{
    procedure Process(
        var GroupRec: Record "RDBC_Base_JnlImp_Staging";
        var Staging: Record "RDBC_Base_JnlImp_Staging";
        var DocNo: Code[20]): Boolean
    var
        GenJnl: Record "Gen. Journal Line";
        TryGeneralJournal: Codeunit "RDBC_Base_TryCreationGenJnl";

    begin
        TryGeneralJournal.SetGroupRec(GroupRec);
        Commit();
        If TryGeneralJournal.Run() then begin
            DocNo := TryGeneralJournal.GetDocNo();
            exit(true);
        end;
        exit(false);
    end;

}