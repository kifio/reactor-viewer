package view

import presenter.Presenter
import java.awt.*
import java.awt.event.MouseAdapter
import java.awt.event.MouseEvent
import java.awt.image.BufferedImage
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import javax.swing.*
import javax.swing.border.EmptyBorder


class View {

    companion object {
        private const val SETUP_DELAY = 500L
    }

    private var presenter: Presenter? = Presenter(this)
    private val delayExecutor = Executors.newSingleThreadScheduledExecutor()
    private val searchField = JTextField()
    private val searchButton = JButton("Search")
    private var galleryList = JList(DefaultListModel<BufferedImage>())

    private lateinit var root: JFrame

    fun setup() {
        root = JFrame("Hello Swing").apply {
            layout = GridBagLayout()

            defaultCloseOperation = JFrame.EXIT_ON_CLOSE
            extendedState = JFrame.MAXIMIZED_BOTH

            isResizable = false
            isVisible = true
        }

        root.setupContent()

        invokeWithDelay({ presenter?.setupCellSize(galleryList.width / 3) }, SETUP_DELAY)
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

    private fun JFrame.addSearchButton(constraints: GridBagConstraints) {
        searchButton.addActionListener {
            presenter?.makeSearch(searchField.text)
        }

        this.add(searchButton, constraints.apply {
            weightx = 1.0
            weighty = 0.0
            fill = GridBagConstraints.HORIZONTAL
            gridx = 4
            gridy = 0
        })
    }

    private fun JFrame.addGrid(constraints: GridBagConstraints) {
        galleryList.selectionMode = ListSelectionModel.SINGLE_INTERVAL_SELECTION;
        galleryList.layoutOrientation = JList.HORIZONTAL_WRAP;
        galleryList.visibleRowCount = -1;
        galleryList.cellRenderer = ImageRenderer()
        galleryList.border = EmptyBorder(4, 0, 0, 0)
        galleryList.addMouseListener(object : MouseAdapter() {
            override fun mouseClicked(e: MouseEvent) {
                presenter?.handleListItemClick(
                    (galleryList.model as DefaultListModel<BufferedImage>)
                    .getElementAt(galleryList.locationToIndex(e.point))
                )
            }
        })

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

    fun update(image: BufferedImage) {
        (galleryList.model as DefaultListModel<BufferedImage>).addElement(image)
    }

    fun clear() {
        (galleryList.model as DefaultListModel<BufferedImage>).clear()
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

    fun showImageInDialog(image: BufferedImage) {
        val frame = JDialog(root, null, true)
        frame.contentPane.add(object : JPanel() {
            override fun paint(g: Graphics) {
                super.paint(g)
                g.drawImage(image, 0, 0, null);
            }
        })
        frame.setSize(image.width, image.height)
        frame.isResizable = false
        frame.isVisible = true
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