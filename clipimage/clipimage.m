(* Wolfram Language Package *)

(* Created by the Wolfram Workbench 2018/12/29 *)

BeginPackage["clipimage`", {"NETLink`"}]
(* Exported symbols added here with SymbolName::usage *) 
clipimage::usage = "clipimage[<graphics>] copies the high resolution graphics to the system clipboard";
wrk$clip;

Begin["`Private`"]
(* Implementation of the package *)
LoadNETAssembly["PresentationCore"];
clipimage[gr_Graphics] := Module[{file, filepng},
	file = CreateFile[];
	filepng = file <> ".png";
	RenameFile[file, filepng];
	(* Export[filepng, gr, ImageResolution -> 300]; *)
	Export[filepng, Magnify[gr,2]];
	wrk$clip[filepng];
];
wrk$clip[fpath_] := Module[{uri, obj},
	uri = NETNew["System.Uri", fpath];
	obj = NETNew["System.Windows.Media.Imaging.BitmapImage", uri];
	(* To load Clipboard class *)
	Quiet[NETNew["System.Windows.Clipboard"]] ;
	System`Windows`Clipboard`SetData["Bitmap", obj];
];

End[]

EndPackage[]

