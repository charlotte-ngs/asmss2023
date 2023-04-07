#' Convert Contrasts to Estimable Function
#'
#' @param pmat_ctr contrasts matrix
#' @param pmat_efun matrix of estimable functions
#'
#' @return either contrasts matrix or matrix of estimable functions depending on input
#' @export ctrm_to_efm
#'
#' @examples
#' ffb <- as.factor(c(rep("Angus", 3), rep("Limousin", 4), rep("Simmental",3)))
#' mat_ctr_trt <- contrasts(ffb)
#' mat_efn_trt <- ctrm_to_efm(pmat_ctr = mat_ctr_trt)
ctrm_to_efm <- function(pmat_ctr = NULL, pmat_efun = NULL){
  if (is.null(pmat_efun)){
    mat_ctr <- cbind(matrix(rep(1, nrow(pmat_ctr)), ncol = 1), pmat_ctr)
    mat_efun <- solve(mat_ctr)
    return(mat_efun)
  } else if (is.null(pmat_ctr)){
    mat_ctr <- solve(pmat_efun)
    mat_ctr <- mat_ctr[,2:3]
    return(mat_ctr)
  } else {
    stop(" *** ERROR: either contrasts matrix or estimable function matrix cannot be NULL, specify one of them")
  }
}



#' Solve Least Squares Normal Equations
#'
#' @param pex_formula formula defining the model
#' @param ptbl_data dataset
#'
#' @return a solution vector
#' @export solve_lsq_norm_eqs
#'
#' @examples
solve_lsq_norm_eqs <- function(pex_formula, ptbl_data){
  # check datatype
  if (! is.element("formula", class(pex_formula)))
    stop(" *** ERROR: pex_formula must be of type formula and not of type: ", class(pex_formula))
  # remove intercept from formula, if not done already
  frm <- pex_formula
  vec_frm <- as.character(frm)
  if (length(grep("0", vec_frm)) == 0L){
    frm <- reformulate(c("0", vec_frm[3]), response = vec_frm[2])
  }
  mat_X <- model.matrix(lm(formula = frm, data = ptbl_data))
  attr(mat_X, "assign") <- NULL
  attr(mat_X, "contrasts") <- NULL
  dimnames(mat_X) <- NULL
  # add back intercept
  mat_X <- cbind(matrix(rep(1, nrow(mat_X)), ncol = 1), mat_X)
  mat_xtx_ginv <- MASS::ginv(crossprod(mat_X))
  mat_xty <- crossprod(mat_X, ptbl_data[[gsub("`", "", vec_frm[2])]])
  mat_b_sol <- crossprod(mat_xtx_ginv, mat_xty)
  return(mat_b_sol)
}