// Package devrel is a no-op Go package.
//
// Hugo never executes this. It exists so a consuming site can:
//
//	import _ "github.com/dadoonet/hugo-theme-devrel"
//
// and keep this module as a *direct* require in go.mod. Dependabot's gomod
// ecosystem ignores dependencies marked // indirect, which is what
// `hugo mod tidy` writes when nothing imports the module.
package devrel
