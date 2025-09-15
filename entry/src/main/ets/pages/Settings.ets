@Entry
@Component
struct Settings {
  @StorageLink('currentIndex') currentIndex: number = 0;
  @StorageLink('animationCount') animationCount: number = 0;
  @State circuit: number = AppStorage.get('circuit') as number;

  @Builder
  CustomButton(image: Resource, action: () => void) {
    Column() {
      Image(image)
        .width(24)
        .height(24)
    }
    .backgroundColor('#ff484848')
    .borderRadius(24)
    .width(46)
    .height(46)
    .clickEffect({
      level: ClickEffectLevel.HEAVY
    })
    .padding(8)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      action()
    })
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Text(`${this.currentIndex + 1} of ${this.animationCount * this.circuit}`)
      }.width('100%').justifyContent(FlexAlign.Center)

      Row({ space: 12 }) {

        this.CustomButton($r('app.media.backward'), () => {
          if (this.currentIndex > 0) {
            this.currentIndex--;
          }
        })

        Image($r('app.media.play')).width(48).height(48).onClick(() => {
          this.getUIContext().getRouter().back()
        })

        this.CustomButton($r('app.media.next'), () => {
          if (this.currentIndex < (this.animationCount * this.circuit) - 1) {
            this.currentIndex++
          }
        })

      }

      Row() {
        this.CustomButton($r('app.media.cross'), () => {
          this.getUIContext().getRouter().clear();
          this.getUIContext().getRouter().replaceUrl({
            url: 'pages/Index'
          })
        })
      }.width('100%').justifyContent(FlexAlign.Center)

    }.width('100%').height('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
  }
}