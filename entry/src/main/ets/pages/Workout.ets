import lottie, { AnimationItem } from '@ohos/lottie';

const TOTAL = 2000

@Entry
@Component
struct Workout {
  @State total: number = TOTAL;
  @State @Watch('handleNext') value: number = TOTAL;
  @State animations: string[] =
    ['squat', 'inchworm', 'jumping', 'plank', 'split_jump', 'burpee_jump', 'single_leg'];
  @StorageLink('animationCount') animationCount: number = this.animations.length;
  @StorageLink('currentIndex') @Watch('handleAnimation') currentIndex: number = 0;
  @State isResting: boolean = false;
  @State circuit: number = AppStorage.get('circuit') as number;
  @State random: Record<string, boolean> = this.getUIContext().getRouter().getParams() as Record<string, boolean>
  private interval: number | null = 0;
  // lottie
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings)
  private animateItem: AnimationItem | null = null;
  private animateName: string = 'animation'; // name

  aboutToAppear(): void {
    this.currentIndex = 0;
    const params: Record<string, string> = this.getUIContext().getRouter().getParams() as Record<string, string>
    if (params.random) {
      this.shuffleArray(this.animations)
    }
  }

  onPageShow(): void {
    this.interval = setInterval(() => {
      this.value -= 10;
    }, 200)
  }

  aboutToDisappear(): void {
    this.destroy();
  }

  handleAnimation() {
    this.total = TOTAL
    this.value = TOTAL
    this.loadAnimation()
  }

  handleNext() {
    if (this.currentIndex > (this.animations.length * this.circuit) - 1) {
      clearInterval(this.interval)
      this.getUIContext().getRouter().clear()
      this.getUIContext().getRouter().replaceUrl({
        url: 'pages/Complete'
      })
    }

    if (this.value < 10) {
      this.currentIndex++;
      this.handleAnimation();
    }

  }

  shuffleArray(array: string[]) {
    for (let i = array.length - 1; i > 0; i--) {
      let j = Math.floor(Date.now() % (i + 1));
      let temp = array[i];
      array[i] = array[j];
      array[j] = temp;
    }
  }

  build() {
    Stack() {
      Progress({ value: this.value, total: this.total, type: ProgressType.Ring }).width('100%').height('100%').style({
        strokeWidth: 10
      })
      Text(this.currentIndex.toString()).fontSize(24).fontColor(Color.White)
      Canvas(this.canvasRenderingContext)
        .width(100)
        .height(100)
        .backgroundColor(Color.Black)
        .foregroundColor(Color.White)
        .onReady(() => {
          // Load the animation.
          if (this.animateItem != null) {
            // Load animations during canvas onReady, ensure that the animation size is correct.
            this.animateItem?.resize();
          } else {
            // Anti-aliasing settings.
            this.canvasRenderingContext.imageSmoothingEnabled = true;
            this.canvasRenderingContext.imageSmoothingQuality = 'medium'
            this.loadAnimation();
          }
        })
    }.onClick(() => {
      clearInterval(this.interval)
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/Settings'
      })
    })
  }

  loadAnimation() {
    this.animateItem = lottie.loadAnimation({
      container: this.canvasRenderingContext,
      renderer: 'canvas', // canvas renderer
      loop: true,
      autoplay: false,
      name: this.animateName,
      contentMode: 'Contain',
      path: `animation/${this.animations[this.currentIndex % this.animations.length]}.json`
    })

    this.animateItem.addEventListener('DOMLoaded', (args: Object): void => {
      this.animateItem?.setSpeed(1.5)
      this.animateItem?.play()
    });
  }

  destroy() {
    this.animateItem?.removeEventListener('DOMLoaded');
    lottie.destroy(this.animateName);
    this.animateItem = null;
  }
}