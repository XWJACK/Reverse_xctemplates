app_name=""
des_macho_path="${SRCROOT}/Resources/${app_name}.app/Contents/MacOS"
des_framewotk_path="${SRCROOT}/Resources/${app_name}.app/Contents/Frameworks"
CODE_SIGN_IDENTITY=""

tweak_dylib="lib${TARGET_NAME}.dylib"
substitute_dylib="libsubstitute.dylib"

# 源文件
ori_tweak_dylib="${BUILT_PRODUCTS_DIR}/${tweak_dylib}"
ori_substitute_dylib="${SRCROOT}/libs/${substitute_dylib}"
ori_macho="${SRCROOT}/Resources/${app_name}"

# 目标文件
des_tweak_dylib="${des_framewotk_path}/${tweak_dylib}"
des_substitute_dylib="${des_macho_path}/${substitute_dylib}"
des_macho="${des_macho_path}/${app_name}"

# Backup origin macho
if [ ! -f "${ori_macho}" ]; then
    cp "${des_macho}" "${ori_macho}"
fi

rm -rf "$des_tweak_dylib"
rm -rf "$des_substitute_dylib"
rm -rf "$des_macho"

# Copy libsubstitute
cp "${ori_substitute_dylib}" "${des_substitute_dylib}"

# Copy Tweak
cp "$ori_tweak_dylib" "$des_tweak_dylib"


#Insert dylib/framework
${SRCROOT}/Tools/insert_dylib --all-yes "@loader_path/../Frameworks/${tweak_dylib}" "${ori_macho}" "${des_macho}"


if [ CODE_SIGN_IDENTITY != "" ]; then
    # Sign
    /usr/bin/codesign --verbose=4 -f -s "$CODE_SIGN_IDENTITY" "$des_substitute_dylib"
    /usr/bin/codesign --verbose=4 -f -s "$CODE_SIGN_IDENTITY" "$des_tweak_dylib"
    # Sign app
    /usr/bin/codesign --verbose=4 -f -s "$CODE_SIGN_IDENTITY" "${SRCROOT}/Resources/${app_name}.app"
fi
