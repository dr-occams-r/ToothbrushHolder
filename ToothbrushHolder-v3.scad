// Toothbrush Holder
//   Easy print, layed down sideways
//   Offset and drying fins in base
//   Configurable number of Brushes
//   Feet to offset from surface to avoid water accumulation under by capilary action.

// Prerequisite:
//   BOSL2 https://github.com/BelfrySCAD/BOSL2
include <BOSL2-local/std.scad>


/* [Body] */
Notes = "";
// Number of toothbrushes
ToothbrushCount = 3; // [0:1:10]
// Hole: 16mm snug, 18mm more general
HoleDiameter = 18; // [0:1:100]
// Holder Height for Standing Toothbrush
Height = 60; // [0:1:500]
// Spacing material between toothbrushe hole edges
Spacing = 10; // [0:1:500]
Depth = 40; // [0:1:100]
// Sides Thickness
Thickness = 4; // [0:1:100]
Rounding = 5; // [0:1:100]
// 35 deg easier overhang and holes overhang permit toothbrushes to lean back and align side-by-side naturally.
OverhangAngle = 35; // [0:1:90]

/* [Dividers] */
// Permits easier printing without crossing outer perimeter.  Stronger support for Horizontal surfaces.  Keeps dripped water constrained to source toothbrush.  Disadvantage water dries a bit slower since less air circulation.
VerticalDividerOption = true;
// Horizontal Divider distance up from top of ridges.  Eg. total empty space height.  Closer make toothbrushes stand straighter depending on how round the end of the toothbrush is, but less aeration for drying the drip tray.
HorizontalDividerGap = 15; // [0:1:100]

/* [Drip Tray with Evaporation Ridges] */
RidgeHeight = 4; // [0:1:20]
// Steeper to keep toothbrush bottom away from water and drain properly.
RidgeAngle = 20; // [0:1:90]


/* [Foot / Feet] */
FootOption = true;
// Foot width and depth
FootSize = 5; // [0:1:10]
FootHeight = 1; // [0:0.1:10]

/* [General] */
VeryThin = 0.001; //[0:0.0001:2]
Tolerance = 0.2; //[0:0.1:2]
SafeFatOffset = 0.4; //[0:0.1:2]

/* [Finalization] */
ShowHolder = true;
PrintHolder = false;
Smooth = true;
FragmentsSmooth = 50; // 5:1:1000
FragmentsRegular = 10; // 5:1:1000
fnCalc = Smooth ? FragmentsSmooth : FragmentsRegular;
$fn = fnCalc;
//echo("fnCalc:", fnCalc);

// Prep Calculations
ToleranceDouble = Tolerance * 2;
SafeFatExtend = SafeFatOffset * 2;
ThicknessDouble = Thickness * 2;
ThicknessHalf = Thickness / 2;

// Angle Calculations
OverhangAngleRatio = tan(90-OverhangAngle);
RidgeAngleRatio = tan(RidgeAngle);

// Body Calculations
HeightHalf = Height / 2;
DepthHalf = Depth / 2;
RepeatLength = Spacing + HoleDiameter;
SpacingTotal = RepeatLength * ToothbrushCount + Spacing;
Length = SpacingTotal - Thickness;
LengthInner = Length - ThicknessDouble;
LengthHalf = Length / 2;
RoundingInner = Rounding - Thickness;

// Hole Calculations
HoleCutoutDown = HeightHalf - Thickness - RidgeHeight;

// Edge Calculations
BotEdgeLength = LengthInner;
BotEdgeHeight = RidgeHeight;
RidgeOverhangeReduce = BotEdgeHeight * OverhangAngleRatio;
RidgeOverhangeReduceDouble = RidgeOverhangeReduce * 2;
BotEdgeThickness = RidgeOverhangeReduce;
BotEdgeThicknessDouble = BotEdgeThickness * 2;
BotEdgeFrontFwd = DepthHalf;

// Ridge Calculations
RidgeThicknessHalf = RidgeHeight * RidgeAngleRatio;
RidgeThickness =  RidgeThicknessHalf * 2;
RidgeLengthBase = Depth - BotEdgeThicknessDouble;
RidgeLengthTip = RidgeLengthBase - RidgeOverhangeReduceDouble;
RidgeSpacing = RidgeThickness;
RidgeDown = HeightHalf - Thickness;
RidgeCount = floor(LengthInner / RidgeSpacing);
RidgeHeightOuter = Thickness + RidgeHeight;

// Dividers
HDividerDown = HeightHalf - RidgeHeightOuter - HorizontalDividerGap;
VDividerCount = ToothbrushCount - 1;

// Feet
FootLength = FootSize;
FootWidth = FootSize;
FootTopWidthExtra = FootHeight * OverhangAngleRatio;
FootTopWidth = FootWidth + FootTopWidthExtra;
FootLeft = LengthHalf - Rounding;
FootBack = DepthHalf;
FootDown = HeightHalf;


module BodyPerimeter(){
  xrot(90){
    rect_tube(
      size=[Length, Height],
      l=Depth,
      wall=Thickness,
      rounding=Rounding,
      irounding=RoundingInner,
      anchor=CENTER
    );
  }
}
//BodyPerimeter();

module BodyFull(){
  hull(){
    BodyPerimeter();
  }
}

module FootBottom(){
  cuboid(
    size=[FootLength, FootWidth, FootHeight],
    anchor=TOP+BACK+LEFT
  );
}

module FootTop(){
  cuboid(
    size=[FootLength, FootTopWidth, VeryThin],
    anchor=TOP+BACK+LEFT
  );
}

module Foot(){
  down(FootDown){
    back(FootBack){
      left(FootLeft){
        hull(){
          FootBottom();
          FootTop();
        }
      }
    }
  }
}
//Foot();

module Foots(){
  xflip_copy(){
    yflip_copy(){
      Foot();
    }
  }
}
//Foots();

module BodyHDivider(){
  down(HDividerDown){
    cuboid(
      size=[Length, Depth, Thickness],
      anchor=BOT
    );
  }
}
//BodyHDivider();

module BodyVDivider(){
  cuboid(
    size=[Thickness, Depth, Height]
  );
}
//BodyVDivider();

module BodyVDividers(){
  xcopies(
    n=VDividerCount,
    spacing=RepeatLength
  ){
    BodyVDivider();
  }
}
//BodyVDividers();


module BotEdgeFront(){
  fwd(BotEdgeFrontFwd){
    hull(){
      // Base
      cuboid(
        size=[BotEdgeLength, BotEdgeThickness, VeryThin],
        anchor=FWD+BOT
      );

      // Tip
      up(BotEdgeHeight){
        cuboid(
          size=[BotEdgeLength, VeryThin, VeryThin],
          anchor=FWD+BOT
        );
      }
    }
  }
}
//BotEdgeFront();

module BotEdges(){
  BotEdgeFront();
  yflip_copy(){
    BotEdgeFront();
  }
}
//BotEdges();


module Ridge(){
  hull(){
    // Base
    cuboid(
      size=[RidgeThickness, RidgeLengthBase, VeryThin],
      anchor=BOT
    );

    // Tip
    up(RidgeHeight){
      cuboid(
        size=[VeryThin, RidgeLengthTip, VeryThin],
        anchor=BOT
      );
    }
  }
}
//Ridge();

module Ridges(){
  xcopies(
    n=RidgeCount,
    spacing=RidgeSpacing
  ){
    Ridge();
  }
}
//Ridges();

module RidgesAll(){
  down(RidgeDown){
    BotEdges();
    Ridges();
  }
}
//RidgesAll();

module BodyRaw(){
  BodyPerimeter();
  BodyHDivider();
  if(VerticalDividerOption){
    BodyVDividers();
  }
  RidgesAll();
}
//BodyRaw();

module BodyCleaned(){
  intersection(){
    BodyFull();
    BodyRaw();
  }
}

module HoleCutout(){
  down(HoleCutoutDown){
    xrot(90){
      teardrop(
        d=HoleDiameter,
        l=Height,
        ang=OverhangAngle,
        anchor=FWD
      );
    }
  }
}
//HoleCutout();

module HoleCutouts(){
  xcopies(
    n=ToothbrushCount,
    spacing=RepeatLength
  ){
    HoleCutout();
    zrot(180){
      HoleCutout();
    }
  }
}
//HoleCutouts();

module Holder(){
  difference(){
    BodyCleaned();
    HoleCutouts();
  }
  if(FootOption){
    Foots();
  }
}

module HolderPrintReady(){
  xrot(-90){
    Holder();
  }
}

module Final(){
  if(PrintHolder){
    HolderPrintReady();
  }else if(ShowHolder){
    Holder();
  }

}

Final();

