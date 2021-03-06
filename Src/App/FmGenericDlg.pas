{
 * FmGenericDlg.pas
 *
 * Implements a dialog box base class that displays and handles a help button,
 * sizes the window, arranges the controls and aligns the dialog box over its
 * parent form.
 *
 * $Rev$
 * $Date$
 *
 * ***** BEGIN LICENSE BLOCK *****
 * 
 * Version: MPL 1.1
 * 
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * 
 * The Original Code is FmGenericDlg.pas.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2004-2011 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit FmGenericDlg;


interface


uses
  // Delphi
  StdCtrls, Controls, ExtCtrls, Classes,
  // Project
  FmBase;


type

  {
  TGenericDlg:
    Generic base class for dialog boxes. Displays and handles help button and
    aligns the dialog box to its owners.
  }
  TGenericDlg = class(TBaseForm)
    bvlBottom: TBevel;
    pnlBody: TPanel;
    btnHelp: TButton;
    procedure btnHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure AlignToOwner;
      {Aligns this dialog box relative to its owner form. Called automatically
      when form is created}
  protected
    procedure ArrangeForm; virtual;
      {Positions controls and sets form size according to body panel dimensions}
    function GetDefaultKeyword: string;
    procedure DisplayHelp; overload;
    procedure DisplayHelp(const AKeyword: string); overload;
  end;


implementation


uses
  // Delphi
  Windows, Forms,
  // Project
  UHelpManager;


{$R *.DFM}


{ TGenericDlg }

procedure TGenericDlg.AlignToOwner;
  {Aligns this dialog box relative to its owner form. Called automatically when
  form is created}
var
  OwnerForm: TForm;     // form that owns this dialog box
  WorkArea: TRect;      // work area rectangle (excludes task bars)
  BoundsR: TRect;       // bounds rect of this form
begin
  // Get form's owning form: get out if there isn't one
  if not (Owner is TForm) then
    Exit;
  OwnerForm := Owner as TForm;

  // Initialise bounding rectangle, positioned at (0,0) on screen
  BoundsR := Rect(0, 0, Self.Width, Self.Height);

  // Offset dialog box over owner form
  if (OwnerForm.BorderStyle in [bsDialog, bsSizeToolWin, bsToolWindow]) then
  begin
    // we're centering over another dlg box - just offset down and left a bit
    OffsetRect(BoundsR, OwnerForm.Left + 40, OwnerForm.Top + 40);
  end
  else
  begin
    // we're probably centering over a main window: we centre horizontally over
    // form & "centre" vertically 1/3rd way down main window}
    OffsetRect(
      BoundsR,
      OwnerForm.Left + (OwnerForm.Width - Self.Width) div 2,
      OwnerForm.Top + (OwnerForm.Height - Self.Height) div 3
    );
  end;
  // if any of borders align with owner form then, offset left and down
  if Abs(BoundsR.Left - OwnerForm.Left) < 7 then
    OffsetRect(BoundsR, 20, 0);
  if Abs(BoundsR.Right - OwnerForm.BoundsRect.Right) < 7 then
    OffsetRect(BoundsR, 20, 0);
  if Abs(BoundsR.Top - OwnerForm.Top) < 7 then
    OffsetRect(BoundsR, 0, 20);
  if Abs(BoundsR.Bottom - OwnerForm.BoundsRect.Bottom) < 7 then
    OffsetRect(BoundsR, 0, 20);

  // Now try to ensure form fits in work area
  // get work area
  WorkArea := Screen.WorkAreaRect;
  // if right edge of form is off work area, move left
  if BoundsR.Right > WorkArea.Right then
    OffsetRect(BoundsR, WorkArea.Right - BoundsR.Right, 0);
  // if left edge of form is off work area move right
  if BoundsR.Left < WorkArea.Left then
    OffsetRect(BoundsR, WorkArea.Left - BoundsR.Left, 0);
  // if bottom edge of form is off work area then move up
  if BoundsR.Bottom > WorkArea.Bottom then
    OffsetRect(BoundsR, 0, WorkArea.Bottom - BoundsR.Bottom);
  // if top edge of form is off work area then move down
  if BoundsR.Top < WorkArea.Top then
    OffsetRect(BoundsR, 0, WorkArea.Top - BoundsR.Top);

  // Finally, set position
  Self.Left := BoundsR.Left;
  Self.Top := BoundsR.Top;
end;

procedure TGenericDlg.ArrangeForm;
  {Positions controls and sets form size according to body panel dimensions}
begin
  ClientWidth := pnlBody.Width + 16;
  bvlBottom.Top := pnlBody.Top + pnlBody.Height + 6;
  // position help button depending on whether bevel is visible
  if bvlBottom.Visible then
    btnHelp.Top := bvlBottom.Top + 8
  else
    btnHelp.Top := bvlBottom.Top;
  ClientHeight := btnHelp.Top + btnHelp.Height + 6;
  bvlBottom.Width := pnlBody.Width;
  btnHelp.Left := ClientWidth - 8 - btnHelp.Width;
end;

procedure TGenericDlg.btnHelpClick(Sender: TObject);
  {Displays default help for the dialog box using inherited DisplayHelp method}
begin
  DisplayHelp;
end;

procedure TGenericDlg.DisplayHelp;
begin
  DisplayHelp(GetDefaultKeyword);
end;

procedure TGenericDlg.DisplayHelp(const AKeyword: string);
begin
  THelpManager.ShowALink(AKeyword, THelpManager.NoDlgHelpTopic);
end;

procedure TGenericDlg.FormCreate(Sender: TObject);
  {Positions components on form and aligns form to any owning form}
begin
  inherited;
  ArrangeForm;
  AlignToOwner;
end;

procedure TGenericDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if (Key = VK_F1) and (Shift * [ssShift, ssCtrl, ssAlt] = []) then
  begin
    Key := 0;
    DisplayHelp;
  end;
end;

function TGenericDlg.GetDefaultKeyword: string;
begin
  if HelpKeyword <> '' then
    Result := HelpKeyword
  else
    Result := Name;
end;

end.
