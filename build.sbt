name := "Fk"

version := "1.0-SNAPSHOT"

libraryDependencies ++= Seq(
  jdbc,
  anorm,
  cache,
  "com.impetus" % "kundera" % "2.8"
)     

play.Project.playScalaSettings
