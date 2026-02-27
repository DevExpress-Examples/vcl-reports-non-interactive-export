program PDFReportGenerator;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes, System.StrUtils, dxBackend, dxBackend.Bundled,
  dxBackend.ConnectionString.SQL, dxReport, dxReport.Parameters;
var
  AOrderID: string;

// Export a report to a PDF file in non-interactive mode:
// without showing the report in the Report Designer or Report Viewer, or otherwise using UI.
// Parameters:
// AOrderID: order ID to use in report data, for example, '11077'
procedure ExportReportToPdf(const AOrderID: string);
var
  AConnection: TdxBackendDatabaseSQLConnection;
  AReport: TdxReport;
  AStream: TMemoryStream;
  AOutputFileName: string;

begin
  // Step 1: Create a report instance and load the report layout
  AReport := TdxReport.Create(nil);
  try
    // Set an internal report name (does not affect the exported PDF content and file name)
    AReport.ReportName := 'OrderReport';
    // Load the report layout from the specified file
    AReport.Layout.LoadFromFile('Order.repx');

    // Step 2: Create a database connection
    AConnection := TdxBackendDatabaseSQLConnection.Create(nil);
    try
      // Assign a database name matching the name specified in the report layout
      AConnection.DisplayName := 'NWindConnectionString';
      // Assign a connection string required to use the local SQLite database
      AConnection.ConnectionString := 'XpoProvider=SQLite; Data Source=nwind.db; Mode=ReadOnly';

      // Step 3: Define Report Parameter Values
      AReport.LoadParametersFromReport;
      // Set the "OrderIdParameter" value in the report layout
      AReport.Parameters['OrderIdParameter'].Value := AOrderID;

      // Step 4: Export a report to PDF
      AStream := TMemoryStream.Create;
      try
        // Export a report to a memory stream in the PDF format
        AReport.ExportToPDF(AStream);
        // Save memory stream content to a file
        AOutputFileName := 'Order_' + AOrderID + '.pdf';
        AStream.SaveToFile(AOutputFileName);
        Writeln('Report saved to: ', AOutputFileName);
      finally
        AStream.Free;
      end;
    finally
      AConnection.Free;
    end;
  finally
    AReport.Free;
  end;
end;

// The helper application entry point that parses command-line parameters and calls the export procedure
begin
  if ParamCount < 1 then
  begin
    Writeln('Error: OrderID parameter is required. For example: PDFReportGenerator.exe 11077');
    Halt(1); // Exit with error code 1
  end;

  AOrderID := ParamStr(1); // Read the first parameter as OrderID
  ExportReportToPdf(AOrderID);
end.
