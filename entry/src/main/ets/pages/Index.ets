import { ArcList, ArcListAttribute, ArcListItem, ArcListItemAttribute, LengthUnit } from '@kit.ArkUI';


@Entry
@Component
struct Index {
  @Builder
  CustomCard(cardIcon: Resource, title: string, subtitle: string, random: boolean = false) {
    Column({ space: 4 }) {
      Row() {
        Image(cardIcon).width(24).height(24)
        Image($r('app.media.dots'))
          .width(24)
          .height(24)
          .padding(4)
          .borderRadius(24)
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/Circuits'
            })
          })
          .stateStyles({
            normal: {
              .backgroundColor('#ff585656')
            },
            pressed: {
              .backgroundColor('#aab3b1b1')
            }
          })

      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(title).fontSize(14).fontWeight(FontWeight.Bold)
      }.width('100%')

      Row() {
        Text(subtitle).fontSize(12).fontColor('#ddd')
      }.width('100%')
    }
    .width('80%')
    .backgroundColor('#ff484848')
    .padding(8)
    .borderRadius(12)
    .onClick(() => {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/Workout',
        params: { random: random }
      })
    })
  }

  build() {
    RelativeContainer() {
      ArcList({ initialIndex: 1 }) {
        ArcListItem() {
          Row() {
            Text('Quick Starters').fontColor(Color.White).fontSize(14).fontWeight(FontWeight.Bold);
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 16 })
        }

        ArcListItem() {
          this.CustomCard($r('app.media.man'), 'Full Body', 'Suggested');
        }.autoScale(false)

        ArcListItem() {
          this.CustomCard($r('app.media.random'), 'Quick Starter', 'Random', true);
        }.autoScale(false)
      }
      .height('100%')
      .space({
        unit: LengthUnit.PX,
        value: 12
      })

    }
    .height('100%')
    .width('100%')
  }
}