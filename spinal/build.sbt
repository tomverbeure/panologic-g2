
lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.github.spinalhdl",
      scalaVersion := "2.11.6",
      version      := "1.0.0"
    )),
    libraryDependencies ++= Seq(
        "com.github.spinalhdl" % "spinalhdl-core_2.11" % "1.2.2",
        "com.github.spinalhdl" % "spinalhdl-lib_2.11"  % "1.2.2",
        "org.scalatest" % "scalatest_2.11" % "2.2.1",
        "org.yaml" % "snakeyaml" % "1.8"
    ),
    name := "panologic-g2"
  ).dependsOn(vexRiscv)
//lazy val vexRiscv = RootProject(uri("git://github.com/SpinalHDL/VexRiscv.git"))
//lazy val vexRiscv = RootProject(file("../../VexRiscv"))

//If you want a specific git commit : 
lazy val vexRiscv = RootProject(uri("git://github.com/SpinalHDL/VexRiscv.git#f54865bcb8fc0de6002365a1a7544af06bac575b"))

//If the dependancy is localy on your computer : 
//lazy val vexRiscv = RootProject(file("local/path/to/the/VexRiscv/sbt/project/VexRiscv"))

addCompilerPlugin("org.scala-lang.plugins" % "scala-continuations-plugin_2.11.6" % "1.0.2")
scalacOptions += "-P:continuations:enable"
fork := true
