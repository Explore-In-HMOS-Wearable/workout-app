import lottie, { AnimationItem } from '@ohos/lottie';
import { WorkoutAnalytics } from '../services/WorkoutAnalytics';
import { FeedbackCue, WorkoutFeedback } from '../services/WorkoutFeedback';

const WORKOUT_TOTAL = 2000
const REST_TOTAL = 500
const TICKS_PER_SECOND = 50

export class WorkoutParams {
  random: boolean = false

  constructor(random: boolean) {
    this.random = random
  }
}

@Component
export struct Workout {
  @Consume('pageStack') pageStack: NavPathStack;
  @State total: number = WORKOUT_TOTAL;
  @State @Watch('handleNext') value: number = WORKOUT_TOTAL;
  private animations: string[] =
    ['squat', 'inchworm', 'jumping', 'plank', 'split_jump', 'burpee_jump', 'single_leg'];
  @StorageLink('animationCount') animationCount: number = this.animations.length;
  @StorageLink('currentIndex') @Watch('handleAnimation') currentIndex: number = 0;
  @State isResting: boolean = false;
  @StorageLink('circuit') circuit: number = 1;
  private interval: number | null = 0;
  // lottie
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings)
  private animateItem: AnimationItem | null = null;
  private animateName: string = 'animation'; // name

  aboutToAppear(): void {
    this.currentIndex = 0;
    this.total = WORKOUT_TOTAL;
    this.value = WORKOUT_TOTAL;
    this.isResting = false;
    const params = this.getWorkoutParams()
    if (params.random) {
      this.shuffleArray(this.animations)
    }
    WorkoutAnalytics.log('workout_started',
      `random=${params.random}, circuit=${this.circuit}, exerciseCount=${this.animations.length}`)
    WorkoutFeedback.play(FeedbackCue.START)
    this.startTimer()
  }

  startTimer(): void {
    if (this.interval !== null) {
      clearInterval(this.interval)
    }
    this.interval = setInterval(() => {
      this.value -= 10;
    }, 200)
  }

  aboutToDisappear(): void {
    if (this.interval !== null) {
      clearInterval(this.interval)
      this.interval = null
    }
    this.destroy();
  }

  handleAnimation() {
    this.isResting = false
    this.total = WORKOUT_TOTAL
    this.value = WORKOUT_TOTAL
    this.loadAnimation()
    WorkoutAnalytics.log('exercise_started',
      `index=${this.currentIndex + 1}, name=${this.animations[this.currentIndex % this.animations.length]}`)
  }

  handleNext() {
    if (this.value > 0) {
      this.playCountdownCue()
      return
    }

    if (this.isResting) {
      this.currentIndex++;
      this.handleAnimation();
      WorkoutFeedback.play(FeedbackCue.START)
      return
    }

    if (this.currentIndex >= (this.animations.length * this.circuit) - 1) {
      this.completeWorkout()
      return
    }

    this.startRest()
  }

  playCountdownCue() {
    const secondsLeft = Math.ceil(this.value / TICKS_PER_SECOND)
    if (secondsLeft > 0 && secondsLeft <= 3 && this.value % TICKS_PER_SECOND === 0) {
      WorkoutFeedback.play(FeedbackCue.COUNTDOWN)
    }
  }

  startRest() {
    this.isResting = true
    this.total = REST_TOTAL
    this.value = REST_TOTAL
    WorkoutFeedback.play(FeedbackCue.REST)
    WorkoutAnalytics.log('rest_started', `completedExercise=${this.currentIndex + 1}, nextExercise=${this.currentIndex + 2}`)
  }

  completeWorkout() {
    if (this.interval !== null) {
      clearInterval(this.interval)
      this.interval = null
    }
    WorkoutFeedback.play(FeedbackCue.COMPLETE)
    WorkoutAnalytics.log('workout_completed',
      `circuit=${this.circuit}, totalExercises=${this.animations.length * this.circuit}`)
    this.pageStack.clear()
    this.pageStack.pushPath({ name: 'Complete' })
  }

  getWorkoutParams(): WorkoutParams {
    const params = this.pageStack.getParamByName('Workout') as WorkoutParams[]
    if (params && params.length > 0) {
      return params[params.length - 1]
    }
    return new WorkoutParams(false)
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
    NavDestination() {
      Stack() {
        Progress({ value: this.value, total: this.total, type: ProgressType.Ring })
          .width('100%')
          .height('100%')
          .style({
            strokeWidth: 10
          })

        Canvas(this.canvasRenderingContext)
          .width(102)
          .height(102)
          .backgroundColor($r('app.color.canvas_background'))
          .foregroundColor($r('app.color.text_primary'))
          .opacity(this.isResting ? 0.16 : 1)
          .borderRadius(51)
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

        Column({ space: 2 }) {
          if (this.isResting) {
            Text($r('app.string.rest_phase'))
              .fontSize(12)
              .fontColor($r('app.color.rest_accent'))
              .fontWeight(FontWeight.Bold)
          } else {
            Text($r('app.string.work_phase'))
              .fontSize(12)
              .fontColor($r('app.color.accent'))
              .fontWeight(FontWeight.Bold)
          }
          Text(`${this.currentIndex + 1}`)
            .fontSize(26)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .backgroundColor($r('app.color.page_background'))
      .onClick(() => {
        if (this.interval !== null) {
          clearInterval(this.interval)
          this.interval = null
        }
        WorkoutFeedback.play(FeedbackCue.CONTROL)
        WorkoutAnalytics.log('workout_paused', `index=${this.currentIndex + 1}, resting=${this.isResting}`)
        this.pageStack.pushPath({ name: 'Settings' })
      })
    }
    .hideTitleBar(true)
    .onShown(() => {
      this.startTimer()
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
