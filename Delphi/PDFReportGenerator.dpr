program PDFReportGenerator;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,
  dxBackend,
  dxBackend.Bundled,
  dxBackend.ConnectionString.SQL,
  dxReport;

procedure ExportReportToPdf;
var
  AManager: TdxBackendDataConnectionManager;
  AConnection: TdxBackendDatabaseSQLConnection;
  AReport: TdxReport;

  AStream: TMemoryStream;

  AIni: TIniFile;

  AParamName: string;
  AKeys: TStringList;
  I: Integer;
begin
  TdxBackend.Instance.Start; // Start the backend

  AManager := TdxBackendDataConnectionManager.Create(nil);
  AIni := TIniFile.Create('..\PDFReportGenerator.ini');
  try
    AConnection := TdxBackendDatabaseSQLConnection(AManager.DataConnections.
      Add(TdxBackendDatabaseSQLConnection));

    AConnection.DisplayName := AIni.ReadString('Connection', 'Name', '');
    AConnection.ConnectionString :=
      AIni.ReadString('Connection', 'ConnectionString', '');
    AConnection.Active := True;

    AReport := TdxReport.Create(nil);
    try
      AReport.Layout.LoadFromFile(AIni.ReadString('Report', 'LayoutFileName', ''));
      AReport.ReportName := 'Report';

      AReport.LoadParametersFromReport;

      AKeys := TStringList.Create;
      try
        for I := 0 to AKeys.Count - 1 do
        begin
          AParamName := AKeys[I];

          if AReport.Parameters.ParamByName[AParamName] <> nil then
            AReport.Parameters
              .ParamByName[AKeys[I]]
              .Value := AIni.ReadString('Parameters', AParamName, '');
        end;
      finally
        AKeys.Free;
      end;

      AStream := TMemoryStream.Create;
      try
        AReport.ExportToPDF(AStream);
        AStream.SaveToFile(AIni.ReadString('Report', 'OutputFileName', ''))
      finally
        AStream.Free;
      end;
    finally
      AReport.Free;
    end;
  finally
    AManager.Free;
    AIni.Free;
  end;
end;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    ExportReportToPdf;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
