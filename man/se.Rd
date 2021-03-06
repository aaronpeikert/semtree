\name{se.semtree}
\alias{se}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  SEMtrees Parameter Estimates Standard Error Table
}
\description{
  Returns a table of standard errors with columns corresponding to freely estimated standard errors and rows corresponding to nodes in the tree.
}
\usage{
  se(tree, leafs.only=TRUE)
}
\arguments{
  \item{tree}{A SEMtree object obtained from \code{\link{semtree}}}
  \item{leafs.only}{Default = TRUE. Only the terminal nodes (leafs) are printed. If set to FALSE, all node standard errors are written to the \code{data.frame}.}
}
\details{
  The row names of the resulting data frame correspond to internal node ids and the column names correspond to standard errors in the SEM. Parameter estimates can be obtained from \code{\link{parameters}}.
}
\value{
  Returns a \code{data.frame} with rows for parameters and columns for terminal nodes.
}
\references{
  Brandmaier, A.M., Oertzen, T. v., McArdle, J.J., & Lindenberger, U. (2013). Structural equation model trees. \emph{Psychological Methods}, 18(1), 71-86.
}
\author{
  Andreas M. Brandmaier, John J. Prindle
}
%\note{
%%  ~~further notes~~
%}

\seealso{
  \code{\link{semtree}},
  \code{\link{semtree.control}},
  \code{\link{parameters}}
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ ~kwd1 }
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
