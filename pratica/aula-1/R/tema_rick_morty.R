tema_rick_morty <- function() {
  # lembrem-se de usar os ::
  theme(
    text = element_text(
      colour = "#11a2c6",
      family = "Get Schwifty",
      size = 16
    ),
    plot.title = element_text(
      family = "Get Schwifty",
      hjust = 0.5,
      size = 30
    ),
    axis.text = element_text(color = "white"),
    axis.ticks.x = element_line(color = "white"),
    panel.background = element_rect(fill = "black"),
    panel.grid.major.y = element_line(size = 0.1),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    legend.background = element_rect(fill = "black", color = "black"),
    plot.background = element_rect(fill = "black", color = "black")
  )
}



scale_fill_rick_morty <- function() {
  scale_fill_manual(values = c("#e89ac7",
                               "#e4a788",
                               "#f0e14a",
                               "#97ce4c",
                               "#44281d"
  ))
}
