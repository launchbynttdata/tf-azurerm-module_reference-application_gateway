package testimpl

import (
	"context"
	"os"
	"strings"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

func TestAppGatewayComplete(t *testing.T, ctx types.TestContext) {
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionId) == 0 {
		t.Fatal("ARM_SUBSCRIPTION_ID environment variable is not set")
	}

	cred, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		t.Fatalf("Unable to get credentials: %v\n", err)
	}

	t.Run("TestAppGatewayID", func(t *testing.T) {
		checkAppGatewayID(t, ctx, subscriptionId, cred)
		checkAppGatewayFirewallId(t, ctx, subscriptionId, cred)
	})
}

func checkAppGatewayID(t *testing.T, ctx types.TestContext, subscriptionId string, cred *azidentity.DefaultAzureCredential) {
	resourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")
	appGatewayID := terraform.Output(t, ctx.TerratestTerraformOptions(), "id")
	appGatewayName := terraform.Output(t, ctx.TerratestTerraformOptions(), "name")

	client := NewApplicationGatewaysClient(t, subscriptionId, cred)

	appGateway, err := client.Get(context.TODO(), resourceGroupName, appGatewayName, nil)
	assert.NoError(t, err, "Failed to retrieve WAF Policy from Azure")

	assert.True(
		t,
		// case insensitive comparison
		strings.EqualFold(appGatewayID, *appGateway.ID),
		"App gateway ID doesn't match",
	)
}

func checkAppGatewayFirewallId(t *testing.T, ctx types.TestContext, subscriptionId string, cred *azidentity.DefaultAzureCredential) {
	resourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")
	appGatewayName := terraform.Output(t, ctx.TerratestTerraformOptions(), "name")
	wafPolicyID := terraform.Output(t, ctx.TerratestTerraformOptions(), "waf_policy_id")

	client := NewApplicationGatewaysClient(t, subscriptionId, cred)

	appGateway, err := client.Get(context.TODO(), resourceGroupName, appGatewayName, nil)
	assert.NoError(t, err, "Failed to retrieve App Gateway from Azure")

	assert.True(
		t,
		// case insensitive comparison
		strings.EqualFold(wafPolicyID, *appGateway.Properties.FirewallPolicy.ID),
		"App gateway WAF Policy ID doesn't match",
	)
}

func NewApplicationGatewaysClient(t *testing.T, subscriptionId string, cred *azidentity.DefaultAzureCredential) *armnetwork.ApplicationGatewaysClient {
	client, err := armnetwork.NewApplicationGatewaysClient(subscriptionId, cred, nil)
	if err != nil {
		t.Fatalf("Error creating Application Gateway client: %v", err)
	}
	return client
}
