package cornerContourWebGLTest;

import cornerContourWebGLTest.HaxeLogo;
import cornerContour.io.Float32Array;
import cornerContour.io.ColorTriangles2D;
import cornerContour.io.IteratorRange;
import cornerContour.io.Array2DTriangles;
// contour code
import cornerContour.Sketcher;
import cornerContour.Pen2D;
import cornerContour.StyleSketch;
import cornerContour.StyleEndLine;
// SVG path parser
import justPath.*;
import justPath.transform.ScaleContext;
import justPath.transform.ScaleTranslateContext;
import justPath.transform.TranslationContext;

import js.html.webgl.RenderingContext;
import js.html.CanvasRenderingContext2D;

// html stuff
import cornerContour.web.Sheet;
import cornerContour.web.DivertTrace;
import cornerContour.shape.Circles;

import htmlHelper.tools.AnimateTimer;
import cornerContour.web.RendererTexture;
import cornerContour.web.Renderer;

// webgl gl stuff
import cornerContour.web.ShaderColor2D;
import cornerContour.web.HelpGL;
import cornerContour.web.BufferGL;
import cornerContour.web.GL;
import cornerContour.web.ImageLoader;

// js webgl 
import js.html.webgl.Buffer;
import js.html.webgl.RenderingContext;
import js.html.webgl.Program;
import js.html.webgl.Texture;

// js generic
import js.Browser;
import js.html.MouseEvent;
import js.html.Event;

function main(){
    new CornerContourWebGL();
}

class CornerContourWebGL {
    // cornerContour specific code
    var sketcher:       Sketcher;
    var pen2Dtexture:   Pen2D;
    var pen2D:          Pen2D;
    // WebGL/Html specific code
    public var gl:               RenderingContext;
    // general
    public var width:            Int;
    public var height:           Int;
    public var mainSheet:        Sheet;
    var divertTrace:             DivertTrace;
    
    var rendererTexture:         RendererTexture;
    var renderer:                Renderer;
    
    public var imageLoader:      ImageLoader;
    var textureDemo = false;
    public function new(){
        divertTrace = new DivertTrace();
        trace('Contour Test');
        width = 1024;
        height = 768;
        creategl();
        // use Pen to draw to Array
        initContours();
        renderer        = { gl: gl, pen: pen2D,        width: width, height: height };
        rendererTexture = { gl: gl, pen: pen2Dtexture, width: width, height: height };
        imageLoader = new ImageLoader( [], setup, true );
        imageLoader.loadEncoded( [ HaxeLogo.png ], [ 'haxeLogo' ] );
    }
    public function setup(){
        rendererTexture.img = imageLoader.imageArr[ 0 ];
        trace( rendererTexture.img );
        rendererTexture.withAlpha();
        rendererTexture.hasImage = true;
        rendererTexture.transformUVArr    = [ 2.,0.,0.
                                 , 0.,2.,0.
                                 , 0.,0.,1.];
        initDraw();
        
    }
    public function initDraw(){
        drawingShape();
        drawingTexture();
        rendererTexture.rearrangeData();
        rendererTexture.setup();
        rendererTexture.modeEnable();
        renderer.rearrangeData();
        renderer.setup();
        renderer.modeEnable();
        setAnimate();
        mainSheet.initMouseGL();
    }
    inline
    function creategl( ){
        mainSheet = new Sheet();
        mainSheet.create( width, height, true );
        gl = mainSheet.gl;
    }
    public
    function initContours(){
        pen2D = new Pen2D( 0xFFffFFff );
        pen2D.currentColor = 0xFFffFFff;
        pen2Dtexture = new Pen2D( 0xFFffFFff );
        pen2Dtexture.currentColor = 0xFFffFFff;
        sketcher = new Sketcher( pen2Dtexture, StyleSketch.Fine, StyleEndLine.no );
    }
    inline 
    function drawingTexture(){
        allRangeTexture = new Array<IteratorRange>();
        pen2Dtexture.pos = 0;
        pen2Dtexture.arr = new Array2DTriangles();
        var st = Std.int( pen2Dtexture.pos );
        for( i in 1...80 ){
            sketcher.width = 7*Math.random()+1.5;
            var rnd0 = 0.6*(1-Math.random()*2);
            var rnd1 = 0.6*(1-Math.random()*2);
            sketcher.moveTo( 10, i*(10+rnd0) );
            sketcher.lineTo( 800, i*(10+rnd1) );
            sketcher.width = 7*Math.random()+1.5;
            sketcher.moveTo( i*(10+rnd0), 10 );
            sketcher.lineTo( i*(10+rnd1), 800 );
        }
        allRangeTexture.push( st...Std.int( pen2Dtexture.pos - 1 ) );
    }
    
    inline
    function drawingShape(){
        allRange = new Array<IteratorRange>();
        pen2D.pos = 0;
        pen2D.arr = new Array2DTriangles();
        
        var s = Std.int( pen2D.pos );
        if( mainSheet.isDown ) {
            circle( pen2D, mainSheet.mouseX, mainSheet.mouseY, 5, 0xFFFF0000 );
        } else {
            //circle( pen2D, x, y, 5, 0x00FF0000 );
        }
        allRange.push( s...Std.int( pen2D.pos - 1 ) );
    }
    var allRange = new Array<IteratorRange>();
    var allRangeTexture = new Array<IteratorRange>();
    inline
    function render(){
        clearAll( gl, width, height, .9, .9, .9, 1. );
        // for black.
        //clearAll( gl, width, height, 0., 0., 0., 1. );
        // draw order irrelevant here
        drawingTexture();
        drawingShape();
        // you can adjust draw order
        renderTexture();
        renderShape();
    }
    inline 
    function renderTexture(){
        rendererTexture.modeEnable();
        rendererTexture.rearrangeData(); // destroy data and rebuild
        rendererTexture.updateData(); // update
        rendererTexture.drawTextureShape( allRangeTexture[0].start...allRangeTexture[0].max, 0x00FFFFFF );
    }
    inline
    function renderShape(){
        //if( mainSheet.isDown ){
        renderer.modeEnable();
        renderer.rearrangeData(); // destroy data and rebuild
        renderer.updateData(); // update
        renderer.drawData( allRange[0].start...allRange[0].max );
            //}
    }
    inline
    function setAnimate(){
        AnimateTimer.create();
        AnimateTimer.onFrame = function( v: Int ) render();
    }
}
