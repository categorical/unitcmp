// See https://aka.ms/new-console-template for more information
using AssetsTools.NET;
using AssetsTools.NET.Extra;
using System.Text.RegularExpressions;
using System;

namespace unitcmp{ class prog{
    static int dcmp(string u){
        var m=new AssetsManager();
        var v=m.LoadBundleFile(u);
        using(var os=File.OpenWrite(String.Format("{0}.dcmp",u)))
        using(var w=new AssetsFileWriter(os))
            v.file.Unpack(w);
        return 0;
    }
    static int cmp(string u){
        var m=new AssetsManager();
        var v=m.LoadBundleFile(u);
        using(var os=File.OpenWrite(String.Format("{0}.cmp",u)))
        using(var w=new AssetsFileWriter(os))
            v.file.Pack(w,AssetBundleCompressionType.LZ4);
        return 0;
    }
    static int test(string u){
        var m=new AssetsManager();
        var b=m.LoadBundleFile(u,true);
        var s=m.LoadAssetsFileFromBundle(b,0,false);
        foreach(var v in s.file.GetAssetsOfType(AssetClassID.GameObject)){
            var o=m.GetBaseField(s,v);

            stderr(
                "name {0} b {1}"
                ,o["m_Name"].AsString
                ,o["m_IsActive"].AsBool
            );
        }
        return 0;
    }

    static int b(Func<string,int> c,List<string> b){
        foreach(string u in b){
            stderr("[\x1b[32mBGN\x1b[0m] {0}",u);
            try{ c(u);}
            catch(Exception err){
                stderr("err {0}",err.Message);
                return 1;
            }
        }
        return 0;
    }
    static void stderr(string c,params object[] b){
        Console.Error.WriteLine(String.Format(c,b));
    }
    private static int usage(int v){
        string s=String.Format(String.Join("\r\n",new string[]{
            "SYNOPSIS:",
            "   {0} -cmp|-dcmp FLE...",
            "OPTION:",
            "   -cmp,--cmp      compress and write as FLE.cmp",
            "   -dcmp,--dcmp    decompress as FLE.dcmp",
            }),System.IO.Path.GetFileName(Environment.GetCommandLineArgs()[0]));
            stderr(s);
            //Environment.Exit(v);
            return v;
    }
    static int Main(string[] argv){
        if(argv.Contains("-h")||argv.Contains("--help"))
            return usage(0);
        List<string> item=new List<string>();
        var c=new Regex(@"^-.*$");
        foreach(string u in argv){
            if(c.Match(u).Success)continue;
            item.Add(u);
        }
        if(item.Count>0){
        if(argv.Contains("-cmp")||argv.Contains("--cmp"))
            return  b(cmp,  item);
        if(argv.Contains("-dcmp")||argv.Contains("--dcmp"))
            return  b(dcmp, item);
        if(argv.Contains("-test"))
            return  b(test, item);
        }
        return usage(1);
    }
}}
