(* ::Package:: *)

(* Wolfram Language Package *)

(* Created by the Wolfram Workbench 2018/12/29 *)

BeginPackage["clipimage`", {"NETLink`"}]
(* Exported symbols added here with SymbolName::usage *) 
clipimage::usage = "clipimage[<graphics>] copies the high resolution graphics to the system clipboard";
wrk$clip;


Begin["`Private`"]
(* Implementation of the package *)
(*
	CopyToClipboard doesn't work well if the graphics is very large
*)

LoadNETAssembly["PresentationCore"];

LoadNETType["System.Windows.Clipboard"] ;
LoadNETType["System.Windows.Media.Imaging.BitmapCacheOption"] ;

clipimage[gr_Graphics] := Module[{file, filepng},
	file = CreateFile[];
	filepng = file <> ".png";
	RenameFile[file, filepng];
	(* High resolution makes Axis too thin *)
	(* Export[filepng, gr, ImageResolution -> 300]; *)
	Export[filepng, Magnify[gr,2]];
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


End[]

EndPackage[]

