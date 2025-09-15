@Entry
@Component
struct Circuits {
  @State circuit: number = AppStorage.get('circuit') as number;

  build() {
    Column({ space: 4 }) {
      Row() {
        Text('Circuits').fontSize(16).fontWeight(FontWeight.Bold)
      }
      .width('100%').justifyContent(FlexAlign.Center)

      Row({ space: 12 }) {
        Button('-').type(ButtonType.Circle)
          .onClick(() => {
            if (this.circuit > 1) {
              this.circuit--
              AppStorage.set('circuit', this.circuit);
            }
          })
        Text(this.circuit.toString())
        Button('+').type(ButtonType.Circle).onClick(() => {
          if (this.circuit < 5) {
            this.circuit++
            AppStorage.set('circuit', this.circuit);
          }
        })
      }
      .width('100')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)

  }
}