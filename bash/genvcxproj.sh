#!/bin/bash
# Here for latest: https://github.com/robotdad/vclinux 
#
# This script generates a VC Linux project file that includes your source files from the directory specified.
# The project type is makefile and it is set to not copy sources since the assumption here is the files have 
#  been mapped to a Windows drive.
#
# This leaves your source in a flat list. 
# To organize your files as seen in your directory use genfilters.sh to generate an accompanying filter file.
#
# The assumption this script has is that your source code is on a Linux machine and that
#  this directory has been mapped to Windows so the code can be edited in Visual Studio.
#
# You can find out more about VC++ for Linux here: http://aka.ms/vslinux
# Usage:
# $1 is the directory of source code to create a project file for
# $2 is file name to create, should be projectname.vcxproj
# $3 is the root of your Windows fodler where these files will be mapped
# the meat of this is after the printheader/footer functions

function printheader(){
 echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<Project DefaultTargets=\"Build\" ToolsVersion=\"15.0\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">
  <ItemGroup Label=\"ProjectConfigurations\">
    <ProjectConfiguration Include=\"Debug|x64\">
      <Configuration>Debug</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <PropertyGroup Label=\"Globals\">
    <ProjectGuid>{354d0c76-faf2-4532-9872-1c2f729f4fb3}</ProjectGuid>
    <Keyword>Linux</Keyword>
    <RootNamespace>makefile</RootNamespace>
    <MinimumVisualStudioVersion>15.0</MinimumVisualStudioVersion>
    <ApplicationType>Linux</ApplicationType>
    <ApplicationTypeRevision>1.0</ApplicationTypeRevision>
    <TargetLinuxPlatform>Generic</TargetLinuxPlatform>
    <LinuxProjectType>{2238F9CD-F817-4ECC-BD14-2524D2669B35}</LinuxProjectType>
  </PropertyGroup>
  <Import Project=\"\$(VCTargetsPath)\Microsoft.Cpp.Default.props\" />
  <PropertyGroup Condition=\"'\$(Configuration)|\$(Platform)'=='Debug|x64'\" Label=\"Configuration\">
    <UseDebugLibraries>true</UseDebugLibraries>
    <ConfigurationType>Makefile</ConfigurationType>
  </PropertyGroup>
  <Import Project=\"\$(VCTargetsPath)\Microsoft.Cpp.props\" />
  <ImportGroup Label=\"ExtensionSettings\" />
  <ImportGroup Label=\"Shared\" />
  <ImportGroup Label=\"PropertySheets\" />
  <PropertyGroup Label=\"UserMacros\" />
  <PropertyGroup Condition=\"'\$(Configuration)|\$(Platform)'=='Debug|x64'\">
    <RemoteBuildCommandLine>make</RemoteBuildCommandLine>
    <RemoteReBuildCommandLine>make</RemoteReBuildCommandLine>
    <RemoteCleanCommandLine>make clean</RemoteCleanCommandLine>
  </PropertyGroup>"
}

function printfooter(){
 echo "  <ItemDefinitionGroup />
  <Import Project=\"\$(VCTargetsPath)\Microsoft.Cpp.targets\" />
  <ImportGroup Label=\"ExtensionTargets\" />
</Project>"
}

function listothers(){
 echo "  <ItemGroup>"
 for i in $(find . -not -path '*/\.*' -type f ! -iname "*.c" ! -iname "*.cpp" ! -iname "*.cc" ! -iname "*.h" ! -iname "*.hpp" ! -iname "*.txt" ! -iname "*.o" ! -iname "*.vcxproj" ! -iname "*.filters")
 do
   d=${i%/*}
   d=${d//\//\\}
   f=${i##*/}
   printf "    <None Include=\"%s\\%s\" />\n" "$d" "$f"
 done
 echo "  </ItemGroup>"
}

function listtxt(){
 echo "  <ItemGroup>"
 for i in $(find . -not -path '*/\.*' -type f -iname "*.txt")
 do
   d=${i%/*}
   d=${d//\//\\}
   f=${i##*/}
   printf "    <Text Include=\"%s\\%s\" />\n" "$d" "$f"
 done
 echo "  </ItemGroup>"
}

function listcompile(){
 echo "  <ItemGroup>"
 for i in $(find . -not -path '*/\.*' -type f -iname "*.c" -or -iname "*.cpp" -or -iname "*.cc")
 do
   d=${i%/*}
   d=${d//\//\\}
   f=${i##*/}
   printf "    <ClCompile Include=\"%s\\%s\" />\n" "$d" "$f"
 done
 echo "  </ItemGroup>"
}


function listinclude(){
 echo "  <ItemGroup>"
 for i in $(find . -not -path '*/\.*' -type f -iname "*.h" -or -iname "*.hpp")
 do
   d=${i%/*}
   d=${d//\//\\}
   f=${i##*/}
   printf "    <ClInclude Include=\"%s\\%s\" />\n" "$d" "$f"
 done
 echo "  </ItemGroup>"
}

cd $1 || exit 2;
touch $2 && test -w $2 || exit 2;
printheader > $2
listothers >> $2
listtxt >> $2
listcompile >> $2
listinclude >> $2
printfooter >> $2
exit
