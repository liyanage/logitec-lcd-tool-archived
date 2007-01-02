#!/bin/sh

if [ ! $BUILD_STYLE = "Release" ]; then
	echo Distribution target requires Release build style
	exit 1
fi

WD=`pwd`

VERSION=`xsltproc infoplist2version.xslt Info.plist`

cd $BUILT_PRODUCTS_DIR
rm -rf tmp *.zip *.dmg

APP=LogitechLCDTool.app
ZIPNAME=LogitechLCDTool_$VERSION.zip
echo creating ZIP $ZIPNAME
#ditto -c -k --norsrc --keepParent dist $ZIPNAME
ditto -c -k --keepParent $APP $ZIPNAME

DMGNAME=LogitechLCDTool_$VERSION.dmg
echo creating DMG $DMGNAME
mkdir tmp
cp -R $APP tmp
cp -R $WD/examples tmp
ln -s /Applications tmp/Applications
hdiutil create -size 5m -srcfolder tmp -fs HFS+ -volname "LogitechLCDTool $VERSION" $DMGNAME

rm -rf tmp

open .

echo uploading binaries to download server
scp *.zip *.dmg www2.entropy.ch:download/

echo uploading appcast to web server
scp $WD/appcast.xml www.entropy.ch:web/software/macosx/lcdtool/


