package view

import presenter.Presenter
import java.awt.Component
import java.awt.GridBagConstraints
import java.awt.GridBagLayout
import java.awt.image.BufferedImage
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import javax.swing.*

class View {

    companion object {
        private const val SETUP_DELAY = 500L
    }

    private var presenter: Presenter? = Presenter(this)
    private val delayExecutor = Executors.newSingleThreadScheduledExecutor()
    private val searchField = JTextField()
    private val searchButton = JButton("Search")
    private var galleryList = JList(DefaultListModel<BufferedImage>())

    fun setup() {
        JFrame("Hello Swing").apply {
            layout = GridBagLayout()

            defaultCloseOperation = JFrame.EXIT_ON_CLOSE
            extendedState = JFrame.MAXIMIZED_BOTH

            isResizable = false
            isVisible = true
        }.setupContent()

        invokeWithDelay({ presenter?.setupCellSize(galleryList.width / 3) }, SETUP_DELAY)
        presenter?.makeSearch("")
    }

    private fun JFrame.setupContent() = GridBagConstraints().apply {
            addSearchField(this)
            addSearchButton(this)
            addGrid(this)
        }

    private fun JFrame.addSearchField(constraints: GridBagConstraints) = add(searchField, constraints.apply {
            weightx = 4.0
            weighty = 0.0
            fill = GridBagConstraints.HORIZONTAL
            gridx = 0
            gridy = 0
        })

    private fun JFrame.addSearchButton(constraints: GridBagConstraints) = add(searchButton, constraints.apply {
            weightx = 1.0
            weighty = 0.0
            fill = GridBagConstraints.HORIZONTAL
            gridx = 4
            gridy = 0
        })

    private fun JFrame.addGrid(constraints: GridBagConstraints) {
        galleryList.selectionMode = ListSelectionModel.SINGLE_INTERVAL_SELECTION;
        galleryList.layoutOrientation = JList.HORIZONTAL_WRAP;
        galleryList.visibleRowCount = -1;
        galleryList.cellRenderer = ImageRenderer()

        add(JScrollPane(galleryList).apply {
            verticalScrollBarPolicy = JScrollPane.VERTICAL_SCROLLBAR_NEVER
            horizontalScrollBarPolicy = JScrollPane.HORIZONTAL_SCROLLBAR_NEVER
        }, constraints.apply {
            weightx = 0.0
            weighty = 1.0
            fill = GridBagConstraints.BOTH
            gridx = 0
            gridy = 1
            gridwidth = 5
        })
    }

    fun update(newImages: List<BufferedImage>) {
        (galleryList.model as DefaultListModel<BufferedImage>).addAll(newImages)
    }

    fun setupCellSize(cellSize: Int) {
        galleryList.fixedCellWidth = cellSize
        galleryList.fixedCellHeight = cellSize
        galleryList.invalidate()
    }

    private fun invokeWithDelay(runnable: Runnable, delay: Long) {
        delayExecutor.schedule<Any?>({
            SwingUtilities.invokeLater(runnable)
            null
        }, delay, TimeUnit.MILLISECONDS)
    }
}

class ImageRenderer : DefaultListCellRenderer() {

    override fun getListCellRendererComponent(
        list: JList<*>?, value: Any, index: Int,
        isSelected: Boolean, cellHasFocus: Boolean
    ): Component {
        return super.getListCellRendererComponent(
            list, ImageIcon(value as BufferedImage), index, isSelected, cellHasFocus
        )
    }
}