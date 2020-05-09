# INSTALL

How to download, test and run.

## Download

```bash
git clone https://github.com/helvm/helct.git
cd helct
```

## Cabal

Compile and run with `cabal`:
```bash
cabal clean && cabal build && cabal test
cabal run helct
```

## Etlas

Compile and run with `etlas`:
```bash
etlas clean && etlas build && etlas test
etlas run helct
```

## Gradle

Compile and run with `gradlew`:
```bash
./gradlew clean -PetaSendMetrics=true
./gradlew compileEta
./gradlew compileTestEta
./gradlew test
./gradlew run
./gradlew shadowJar
```

## Other

For more see [CONTRIBUTING](../developers/CONTRIBUTING.md).

## 🦄 🌈 ❤️ 💛 💚 💙 🤍 🖤
