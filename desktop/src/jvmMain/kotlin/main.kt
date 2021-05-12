
import javax.swing.JFrame


fun main(args: Array<String>) {
    val frame = JFrame("Hello Swing")
    frame.defaultCloseOperation = JFrame.EXIT_ON_CLOSE
    frame.setSize(300, 100)
    frame.isVisible = true
}