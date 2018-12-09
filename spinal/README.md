In the case where https://github.com/SpinalHDL/SpinalTemplateSbt isn't enough because you want to include some third party SBT project (local or from remote on a git repository), you can use this SpinalTemplateSbtDependencies as a template.

For instance this SpinalTemplateSbtDependencies repo depend on https://github.com/SpinalHDL/VexRiscv/tree/master/src/main/scala/vexriscv.

The only difference with the https://github.com/SpinalHDL/SpinalTemplateSbt are in the https://github.com/SpinalHDL/SpinalTemplateSbtDependencies/blob/superproject/build.sbt file. Just look at it, it is straight forward.

