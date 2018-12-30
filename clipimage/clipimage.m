(* ::Package:: *)

(* Wolfram Language Package *)

(* Created by the Wolfram Workbench 2018/12/29 *)

BeginPackage["clipimage`", {"NETLink`"}]
(* Exported symbols added here with SymbolName::usage *) 
clipimage::usage = "clipimage[<graphics>] copies the high resolution graphics to the system clipboard";
wrk$clip;
addDockedCell::usage = "addDockedCell; add a docked cell with a copy button";


Begin["`Private`"]
(* Implementation of the package *)
(*
	CopyToClipboard doesn't work well if the graphics is very large
*)

LoadNETAssembly["PresentationCore"];

LoadNETType["System.Windows.Clipboard"] ;
LoadNETType["System.Windows.Media.Imaging.BitmapCacheOption"] ;

const$wide = 4000;
const$res = 600;

clipimage[gr_Cell] := wrk$clipimage@Module[{sz, rgr},
	sz = CurrentValue[gr, ImageSize];
	If[MatchQ[sz, $Failed], sz = {Automatic, Automatic}];
	rgr = Rasterize[MapAt[Append[#, ImageSize -> sz] &, gr,
		Position[gr, GraphicsBox[{Except[_RasterBox], ___}, ___] (* except Legend *)
			, Infinity]],
		Background -> White, ImageResolution -> const$res, ImageFormattingWidth -> const$wide];
	rgr
];

(* Magnify is used instead of Resolution specification because High Resolution rasterization
	makes the axis to thin *)
	
clipimage[gr_] := wrk$clipimage[
	Rasterize[Magnify[ToExpression@gr, 2], Background -> White, ImageFormattingWidth -> const$wide]];

wrk$clipimage[gr_] := Module[{file, filepng},
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
    
End[]

EndPackage[]

