#### LLVM_10 Hikari 适配  
由于 FunctionCallObfuscate  有bug未修复，所以 把 -enable-fco 从  -enable-allobf 中剥离。

LLVM_10路径下为已适配过的文件，直接编译即可

```
cd LLVM_10&&mkdir build&&cd build;
cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_CREATE_XCODE_TOOLCHAIN=ON -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi" ../llvm/
make -j7;
sudo make install-xcode-toolchain;
mv /usr/local/Toolchains  /Library/Developer/;
```
