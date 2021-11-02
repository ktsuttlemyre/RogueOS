# run with options python or node as yaml parsers
#this will install meta-package-manager and 
packageFile = "pack.yaml"

#This should work on any os as it levereages meta-package-manager
# but it has been devloped and tested with Mac Big Sur OS

#mac comes with python installed so trigger an xcode install
#trigger python xcode install on mac
# python --version
# python2 --version
# python3 --version

case "$(uname -s)" in
    Linux*)     machine=linux;;
    Darwin*)    machine=mac;;
    CYGWIN*)    machine=cygwin;;
    MINGW32*)     machine=mingw
                  arch=32
         ;;
    MINGW64*)     machine=mingw
                  arch=64
         ;;
    *)          machine="UNKNOWN:$(uname -s)"
esac

if [ machine == "mac" ]; then
    # Do something under Mac OS X platform 
    
   if ! tmp_location="$(type -p "$brew")" || [[ -z $tmp_location ]]; then
     #install brew
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   fi
    
   #install cask for ui programs
   brew tap homebrew/homebrew-cask
   brew install brew-cask

   brew install python #should install pip too

   pip install meta-package-manager
   pip install pyyaml
fi

PACKAGES = ''
function getPackagesJSON() #list, tags, attr, value
{ 
    local  retval= $(echo $packageFile | python3 - "$SHELL" << 'END'
    import sys, json;
        print('Testing $SHELL '+"$SHELL"+' '+sys.argv[1])
        print(json.load(sys.stdin)['$1'].join(' '))
    END)
    IFS=' ' read -r -a PACKAGES <<< "$retval"
}


#iterate all terminal packages
$(getPackages 'default'
for i in "${PACKAGES[@]}"
do
   brew install "$i"
done
# You can access them using echo "${arr[0]}", "${arr[1]}" also

#iterate all gui packages
$(getPackages 'gui')
for i in "${PACKAGES[@]}"
do
   brew install --cask "$i"
done


#iterate opeing apps to finsh installing
$(getPackages 'gui')
for i in "${PACKAGES[@]}"
do
   open -a "$i"
done


