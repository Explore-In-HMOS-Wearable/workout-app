@Entry
@Component
struct Complete {
  build() {
    Column({ space: 4 }) {
      Text('WORKOUT COMPLETE')
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .wordBreak(WordBreak.BREAK_WORD);
      Button('Done')
        .type(ButtonType.ROUNDED_RECTANGLE)
        .width(60)
        .onClick(() => {
          this.getUIContext().getRouter().clear()
          this.getUIContext().getRouter().replaceUrl({
            url: 'pages/Index'
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}