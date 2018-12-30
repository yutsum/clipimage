(* ::Package:: *)

(* Wolfram Language Package *)

(* Created by the Wolfram Workbench 2018/12/29 *)

BeginPackage["clipimage`", {"NETLink`"}]
(* Exported symbols added here with SymbolName::usage *) 
clipimage::usage = "clipimage[<graphics>] copies the high resolution graphics to the system clipboard";
wrk$clip;
addDockedCell::usage = "addDockedCell; add a docked cell with a copy button";


Begin["`Private`"];

Clear["`*"];
(* Implementation of the package *)
(*
	CopyToClipboard doesn't work well if the graphics is very large
*)

LoadNETAssembly["PresentationCore"];

LoadNETType["System.Windows.Clipboard"] ;
LoadNETType["System.Windows.Media.Imaging.BitmapCacheOption"] ;

const$mag = 2;
const$res = 600;
g$wide = 4000;

(* if cell is given, user is selecting a cell (object) *)
clipimage[gr_Cell] := Module[{},
	g$wide = const$mag AbsoluteOptions[First[SelectedCells[]], CellSize][[1, 2, 1]];
	wrk$clipimage[First[gr]];
];
clipimage[gr_] := wrk$clipimage[gr];

(* Magnify is used instead of Resolution specification because High Resolution rasterization
	makes the axis to thin *)
wrk$clipimage[gr_GraphicsBox | gr_BoxData | gr_TemplateBox | gr_TagBox | gr_?boxQ] := wrk$printing[
	Rasterize[Magnify[ToExpression@gr, const$mag], Background -> White, ImageFormattingWidth -> g$wide]];
wrk$clipimage[gr_Graphics] := wrk$printing[
	Rasterize[Magnify[gr, const$mag], Background -> White, ImageFormattingWidth -> g$wide]];
wrk$clipimage[gr_] := wrk$printing[
	Rasterize[Magnify[ToExpression@gr, const$mag], Background -> White, ImageFormattingWidth -> g$wide]];

wrk$printing[gr_] := Module[{file, filepng},
	file = CreateFile[];
	filepng = file <> ".png";
	RenameFile[file, filepng];
	Export[filepng, gr];
	wrk$clip[filepng];
	DeleteFile[filepng];
];


wrk$clip[fpath_] := Module[{uri, obj},
	NETBlock[
		uri = NETNew["System.Uri", fpath];
		obj = NETNew["System.Windows.Media.Imaging.BitmapImage"];
		obj@BeginInit[];
		obj@UriSource = uri;
		obj@CacheOption = System`Windows`Media`Imaging`BitmapCacheOption`OnLoad;
		obj@EndInit[];
		(* To load Clipboard class *)
		System`Windows`Clipboard`SetData["Bitmap", obj];
	]
];

addDockedCell := 
 Cell[BoxData[
   ButtonBox["\"CopyGraphics\"", Appearance -> Automatic, 
    ButtonFunction :> clipimage[NotebookRead[InputNotebook[]]], 
    Evaluator -> Automatic, Method -> "Preemptive"]]];

CurrentValue[EvaluationNotebook[], DockedCells] = addDockedCell;
    
boxQ[x_] /; 
  MatchQ[Head[x], _Symbol] \[And] 
   StringContainsQ[SymbolName@Head[x], "Box" ~~ EndOfString] := True
boxQ[x_] := False

End[]

EndPackage[]

