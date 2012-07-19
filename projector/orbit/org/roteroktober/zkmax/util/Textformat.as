
class org.roteroktober.zkmax.util.Textformat 
{

    public static function stripText(str:String):String 
    {
        return str
    }
    /*
    var lines = entry.body.split("\n").slice(1);
    var abstand = 20;
    var y = 0;
    
    for ( var n=0; n<lines.length; n++ ) {
        if(lines[n] != "") {
            var lmc = body.gitter.line_mc.duplicateMovieClip("line_"+n,body.getNextHighestDepth());
            lmc._y = y;
            body.createTextfield("textline_"+n,body.getNextHighestDepth(),0,y,500,20);
            var tf = body["textline_"+n];
            tf.multiline = false;
            tf.wordWrap = false;
            tf.border = false;
            tf.embedFonts = true;
            
            var ttf = new TextFormat();
            ttf.font = "verdana"
            ttf.size = 20
            ttf.color = 0x000000;
            ttf.bullet = false;
            ttf.underline = false;

            tf.text = lines[n];
            tf.setTextFormat(ttf);
        } 
        y += abstand;            
    };
    */
}