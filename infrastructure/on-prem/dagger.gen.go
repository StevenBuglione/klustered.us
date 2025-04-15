// Code generated by dagger. DO NOT EDIT.

package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"os"
	"sort"

	"github.com/vektah/gqlparser/v2/gqlerror"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/sdk/resource"
	semconv "go.opentelemetry.io/otel/semconv/v1.26.0"
	"go.opentelemetry.io/otel/trace"

	"dagger/dagger/internal/dagger"
	"dagger/dagger/internal/querybuilder"
	"dagger/dagger/internal/telemetry"
)

var dag = dagger.Connect()

func Tracer() trace.Tracer {
	return otel.Tracer("dagger.io/sdk.go")
}

// used for local MarshalJSON implementations
var marshalCtx = context.Background()

// called by main()
func setMarshalContext(ctx context.Context) {
	marshalCtx = ctx
	dagger.SetMarshalContext(ctx)
}

type DaggerObject = querybuilder.GraphQLMarshaller

type ExecError = dagger.ExecError

// ptr returns a pointer to the given value.
func ptr[T any](v T) *T {
	return &v
}

// convertSlice converts a slice of one type to a slice of another type using a
// converter function
func convertSlice[I any, O any](in []I, f func(I) O) []O {
	out := make([]O, len(in))
	for i, v := range in {
		out[i] = f(v)
	}
	return out
}

func (r Dagger) MarshalJSON() ([]byte, error) {
	var concrete struct{}
	return json.Marshal(&concrete)
}

func (r *Dagger) UnmarshalJSON(bs []byte) error {
	var concrete struct{}
	err := json.Unmarshal(bs, &concrete)
	if err != nil {
		return err
	}
	return nil
}

func main() {
	ctx := context.Background()

	// Direct slog to the new stderr. This is only for dev time debugging, and
	// runtime errors/warnings.
	slog.SetDefault(slog.New(slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{
		Level: slog.LevelWarn,
	})))

	if err := dispatch(ctx); err != nil {
		os.Exit(2)
	}
}

func convertError(rerr error) *dagger.Error {
	var gqlErr *gqlerror.Error
	if errors.As(rerr, &gqlErr) {
		dagErr := dag.Error(gqlErr.Message)
		if gqlErr.Extensions != nil {
			keys := make([]string, 0, len(gqlErr.Extensions))
			for k := range gqlErr.Extensions {
				keys = append(keys, k)
			}
			sort.Strings(keys)
			for _, k := range keys {
				val, err := json.Marshal(gqlErr.Extensions[k])
				if err != nil {
					fmt.Println("failed to marshal error value:", err)
				}
				dagErr = dagErr.WithValue(k, dagger.JSON(val))
			}
		}
		return dagErr
	}
	return dag.Error(rerr.Error())
}

func dispatch(ctx context.Context) (rerr error) {
	ctx = telemetry.InitEmbedded(ctx, resource.NewWithAttributes(
		semconv.SchemaURL,
		semconv.ServiceNameKey.String("dagger-go-sdk"),
		// TODO version?
	))
	defer telemetry.Close()

	// A lot of the "work" actually happens when we're marshalling the return
	// value, which entails getting object IDs, which happens in MarshalJSON,
	// which has no ctx argument, so we use this lovely global variable.
	setMarshalContext(ctx)

	fnCall := dag.CurrentFunctionCall()
	defer func() {
		if rerr != nil {
			if err := fnCall.ReturnError(ctx, convertError(rerr)); err != nil {
				fmt.Println("failed to return error:", err)
			}
		}
	}()

	parentName, err := fnCall.ParentName(ctx)
	if err != nil {
		return fmt.Errorf("get parent name: %w", err)
	}
	fnName, err := fnCall.Name(ctx)
	if err != nil {
		return fmt.Errorf("get fn name: %w", err)
	}
	parentJson, err := fnCall.Parent(ctx)
	if err != nil {
		return fmt.Errorf("get fn parent: %w", err)
	}
	fnArgs, err := fnCall.InputArgs(ctx)
	if err != nil {
		return fmt.Errorf("get fn args: %w", err)
	}

	inputArgs := map[string][]byte{}
	for _, fnArg := range fnArgs {
		argName, err := fnArg.Name(ctx)
		if err != nil {
			return fmt.Errorf("get fn arg name: %w", err)
		}
		argValue, err := fnArg.Value(ctx)
		if err != nil {
			return fmt.Errorf("get fn arg value: %w", err)
		}
		inputArgs[argName] = []byte(argValue)
	}

	result, err := invoke(ctx, []byte(parentJson), parentName, fnName, inputArgs)
	if err != nil {
		var exec *dagger.ExecError
		if errors.As(err, &exec) {
			return exec.Unwrap()
		}
		return err
	}
	resultBytes, err := json.Marshal(result)
	if err != nil {
		return fmt.Errorf("marshal: %w", err)
	}

	if err := fnCall.ReturnValue(ctx, dagger.JSON(resultBytes)); err != nil {
		return fmt.Errorf("store return value: %w", err)
	}
	return nil
}
func invoke(ctx context.Context, parentJSON []byte, parentName string, fnName string, inputArgs map[string][]byte) (_ any, err error) {
	_ = inputArgs
	switch parentName {
	case "Dagger":
		switch fnName {
		case "ContainerEcho":
			var parent Dagger
			err = json.Unmarshal(parentJSON, &parent)
			if err != nil {
				panic(fmt.Errorf("%s: %w", "failed to unmarshal parent object", err))
			}
			var stringArg string
			if inputArgs["stringArg"] != nil {
				err = json.Unmarshal([]byte(inputArgs["stringArg"]), &stringArg)
				if err != nil {
					panic(fmt.Errorf("%s: %w", "failed to unmarshal input arg stringArg", err))
				}
			}
			return (*Dagger).ContainerEcho(&parent, stringArg), nil
		case "GrepDir":
			var parent Dagger
			err = json.Unmarshal(parentJSON, &parent)
			if err != nil {
				panic(fmt.Errorf("%s: %w", "failed to unmarshal parent object", err))
			}
			var directoryArg *dagger.Directory
			if inputArgs["directoryArg"] != nil {
				err = json.Unmarshal([]byte(inputArgs["directoryArg"]), &directoryArg)
				if err != nil {
					panic(fmt.Errorf("%s: %w", "failed to unmarshal input arg directoryArg", err))
				}
			}
			var pattern string
			if inputArgs["pattern"] != nil {
				err = json.Unmarshal([]byte(inputArgs["pattern"]), &pattern)
				if err != nil {
					panic(fmt.Errorf("%s: %w", "failed to unmarshal input arg pattern", err))
				}
			}
			return (*Dagger).GrepDir(&parent, ctx, directoryArg, pattern)
		default:
			return nil, fmt.Errorf("unknown function %s", fnName)
		}
	case "":
		return dag.Module().
			WithDescription("A generated module for Dagger functions\n\nThis module has been generated via dagger init and serves as a reference to\nbasic module structure as you get started with Dagger.\n\nTwo functions have been pre-created. You can modify, delete, or add to them,\nas needed. They demonstrate usage of arguments and return types using simple\necho and grep commands. The functions can be called from the dagger CLI or\nfrom one of the SDKs.\n\nThe first line in this comment block is a short description line and the\nrest is a long description with more detail on the module's purpose or usage,\nif appropriate. All modules should have a short description.\n").
			WithObject(
				dag.TypeDef().WithObject("Dagger", dagger.TypeDefWithObjectOpts{SourceMap: dag.SourceMap("main.go", 22, 6)}).
					WithFunction(
						dag.Function("ContainerEcho",
							dag.TypeDef().WithObject("Container")).
							WithDescription("Returns a container that echoes whatever string argument is provided").
							WithSourceMap(dag.SourceMap("main.go", 25, 1)).
							WithArg("stringArg", dag.TypeDef().WithKind(dagger.TypeDefKindStringKind), dagger.FunctionWithArgOpts{SourceMap: dag.SourceMap("main.go", 25, 32)})).
					WithFunction(
						dag.Function("GrepDir",
							dag.TypeDef().WithKind(dagger.TypeDefKindStringKind)).
							WithDescription("Returns lines that match a pattern in the files of the provided Directory").
							WithSourceMap(dag.SourceMap("main.go", 30, 1)).
							WithArg("directoryArg", dag.TypeDef().WithObject("Directory"), dagger.FunctionWithArgOpts{SourceMap: dag.SourceMap("main.go", 30, 47)}).
							WithArg("pattern", dag.TypeDef().WithKind(dagger.TypeDefKindStringKind), dagger.FunctionWithArgOpts{SourceMap: dag.SourceMap("main.go", 30, 79)}))), nil
	default:
		return nil, fmt.Errorf("unknown object %s", parentName)
	}
}
