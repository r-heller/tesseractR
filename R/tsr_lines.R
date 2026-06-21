#' @keywords internal
#' @noRd
.tsr_coord_to_idx <- function(i, j, k, l) {
  as.integer(1L + i + 4L * j + 16L * k + 64L * l)
}

#' @keywords internal
#' @noRd
.tsr_idx_to_coord <- function(idx) {
  z <- as.integer(idx) - 1L
  i <- z %% 4L
  j <- (z %/% 4L) %% 4L
  k <- (z %/% 16L) %% 4L
  l <- (z %/% 64L) %% 4L
  cbind(i = i, j = j, k = k, l = l)
}

#' @keywords internal
#' @noRd
.tsr_directions <- function() {
  g <- expand.grid(
    di = -1L:1L, dj = -1L:1L, dk = -1L:1L, dl = -1L:1L,
    KEEP.OUT.ATTRS = FALSE
  )
  m <- as.matrix(g)
  storage.mode(m) <- "integer"
  nonzero <- rowSums(m != 0L) > 0L
  m <- m[nonzero, , drop = FALSE]
  first_nz <- vapply(seq_len(nrow(m)), function(r) {
    nz <- which(m[r, ] != 0L)
    m[r, nz[1L]]
  }, integer(1L))
  m <- m[first_nz == 1L, , drop = FALSE]
  stopifnot(nrow(m) == 40L)
  colnames(m) <- c("di", "dj", "dk", "dl")
  m
}

#' @keywords internal
#' @noRd
.tsr_compute_win_lines <- function() {
  dirs <- .tsr_directions()
  out <- vector("list", nrow(dirs) * 256L)
  pos <- 0L
  axes <- 0L:3L
  starts <- expand.grid(i = axes, j = axes, k = axes, l = axes,
                        KEEP.OUT.ATTRS = FALSE)
  starts <- as.matrix(starts)
  storage.mode(starts) <- "integer"
  for (d in seq_len(nrow(dirs))) {
    di <- dirs[d, 1L]; dj <- dirs[d, 2L]
    dk <- dirs[d, 3L]; dl <- dirs[d, 4L]
    i3 <- starts[, 1L] + 3L * di
    j3 <- starts[, 2L] + 3L * dj
    k3 <- starts[, 3L] + 3L * dk
    l3 <- starts[, 4L] + 3L * dl
    ok <- i3 >= 0L & i3 <= 3L & j3 >= 0L & j3 <= 3L &
          k3 >= 0L & k3 <= 3L & l3 >= 0L & l3 <= 3L
    s <- starts[ok, , drop = FALSE]
    if (nrow(s) == 0L) next
    line <- cbind(
      .tsr_coord_to_idx(s[, 1L],          s[, 2L],          s[, 3L],          s[, 4L]),
      .tsr_coord_to_idx(s[, 1L] + di,     s[, 2L] + dj,     s[, 3L] + dk,     s[, 4L] + dl),
      .tsr_coord_to_idx(s[, 1L] + 2L*di,  s[, 2L] + 2L*dj,  s[, 3L] + 2L*dk,  s[, 4L] + 2L*dl),
      .tsr_coord_to_idx(s[, 1L] + 3L*di,  s[, 2L] + 3L*dj,  s[, 3L] + 3L*dk,  s[, 4L] + 3L*dl)
    )
    storage.mode(line) <- "integer"
    for (r in seq_len(nrow(line))) {
      pos <- pos + 1L
      out[[pos]] <- sort(line[r, ])
    }
  }
  out <- out[seq_len(pos)]
  lines <- do.call(rbind, out)
  storage.mode(lines) <- "integer"
  key <- apply(lines, 1L, function(row) paste(row, collapse = "-"))
  lines <- lines[!duplicated(key), , drop = FALSE]
  # 4-in-a-row on 4x4x4x4 gives ((4+2)^4 - 4^4)/2 = 520 lines.
  stopifnot(nrow(lines) == 520L)
  colnames(lines) <- c("c1", "c2", "c3", "c4")
  lines
}

#' @keywords internal
#' @noRd
.tsr_win_lines <- function() {
  if (is.null(.tsr_cache[["win_lines"]])) {
    .tsr_cache[["win_lines"]] <- .tsr_compute_win_lines()
  }
  .tsr_cache[["win_lines"]]
}
