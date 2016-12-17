unit UTaskTypes;
 устарел
interface

Type
  // MessAdd
  TMessageClass = ({0}mecApp, {1}mecSQL, {3}mecSecurity, {4}mecDebug, {5}mecTransport, {6}mecTransfer);
  TMessageStyle = ({0}mesError, {1}mesInformation, {2}mesWarning);
// Constants for TMessClass
type
  TMessClass = Integer;
const
  xmecApp      :TMessClass=1;
  xmecSQL      :TMessClass=2;
  xmecDebug    :TMessClass=4;
  xmecSecurety :TMessClass=8;
  xmecTransport:TMessClass=16;
  xmecTransfer :TMessClass=32;
Type
// Constants for TMessStyle
  TMessStyle = Integer;
const
  xmesError   :TMessStyle=1;
  xmesInfo    :TMessStyle=2;
  xmesWarning :TMessStyle=4;
Type
  //..
  TSTTaskStatus = ({0}tssNoTask, {1}tssQueue, {2}tssExecute, {3}tssComplete, {4}tssError);
implementation
end.
