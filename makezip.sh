rm -rf dist
mkdir dist
cd dist
cp -r ../src/* .
cp -r ../samples ./samples
zip -r ../spinehx.zip *
cd ..


