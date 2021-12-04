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

function main(){
    new CornerContourWebGL();
}

class CornerContourWebGL {
    // cornerContour specific code
    var sketcher:       Sketcher;
    var pen2D:          Pen2D;
    // WebGL/Html specific code
    public var gl:               RenderingContext;
    // general
    public var width:            Int;
    public var height:           Int;
    public var mainSheet:        Sheet;
    var divertTrace:             DivertTrace;
    var renderer:                RendererTexture;
    public var imageLoader:      ImageLoader;
    
    public function new(){
        divertTrace = new DivertTrace();
        trace('Contour Test');
        width = 1024;
        height = 768;
        creategl();
        // use Pen to draw to Array
        initContours();
        renderer = { gl: gl, pen: pen2D, width: width, height: height };
        imageLoader = new ImageLoader( [], setup, true );
        imageLoader.loadEncoded( [ HaxeLogo.png ], [ 'haxeLogo' ] );
    }
    public function setup(){
        renderer.img = imageLoader.imageArr[ 0 ];
        trace( renderer.img );
        renderer.withAlpha();
        renderer.hasImage = true;
        renderer.transformUVArr    = [ 2.,0.,0.
                                     , 0.,2.,0.
                                     , 0.,0.,1.];
        
        initDraw();
    }
    public function initDraw(){
        drawing();
        renderer.rearrangeData();
        renderer.setup();
        renderer.modeEnable();
        setAnimate();
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
        sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.no );
    }
    public function drawing(){
        pen2D.pos = 0;
        pen2D.arr = new Array2DTriangles();
        var s = Std.int( pen2D.pos );
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
        allRange.push( s...Std.int( pen2D.pos - 1 ) );
    }

    var allRange = new Array<IteratorRange>();
    inline
    function render(){
        clearAll( gl, width, height, .9, .9, .9, 1. );
        drawing();
        renderer.rearrangeData(); // destroy data and rebuild
        renderer.updateData(); // update
        renderer.drawTextureShape( allRange[0].start...allRange[0].max, 0x00FFFFFF );
    }
    inline
    function setAnimate(){
        AnimateTimer.create();
        AnimateTimer.onFrame = function( v: Int ) render();
    }
}